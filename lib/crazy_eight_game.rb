require 'JSON'
require 'rest-client'
require 'pry'

class CrazyEightGame < ActiveRecord::Base

    def new_deck
        self.deck_id = JSON.parse(RestClient.get("https://deckofcardsapi.com/api/deck/new/shuffle/"))['deck_id']
        update_remaining(JSON.parse(RestClient.get("https://deckofcardsapi.com/api/deck/new/shuffle/"))['remaining'])
        save
    end

    def draw_from_api(count)
        response = RestClient.get("https://deckofcardsapi.com/api/deck/#{deck_id}/draw/?count=#{count}")
        update_remaining(JSON.parse(response)['remaining'])
        JSON.parse(response)['cards']
    end

    def deal_start_hand(player)
        draw_from_api(7).each do |c| 
            Hand.create(location: player, deck_id: deck_id, suit: c['suit'], value: c['value'], code: c['code'])
        end
    end

    def place_start_card
        card_hash = draw_from_api(1)[0]
        Hand.create(location: 'top', deck_id: deck_id, suit: card_hash['suit'], value: card_hash['value'], code: card_hash['code'])
    end

    def draw_card(location)
        hash = draw_from_api(1)[0]
        card = Hand.create(location: location, deck_id: deck_id, suit: hash['suit'], value: hash['value'], code: hash['code'])
        if location != 'computer'
            puts "You drew a #{hash['value'].downcase} of #{pretty_suits(hash['suit'])}. Its play code is #{hash['code'].cyan}."
            puts "There are #{remaining} cards left in the deck."
        end
        puts 'There are no more cards to draw. Cats game, everyone loses.'.red if remaining.zero?
        card
    end

    def turn_tracker
        self.turn_count += 1
        save
    end

    def update_remaining(new_remainder)
        self.remaining = new_remainder
        save
    end

    def find_top_card
        Hand.where('location = ? AND deck_id = ?', 'top', deck_id)[0]
    end

    def view_top_card
        card = find_top_card
        suit = pretty_suits(card['suit'])
        if card.value.nil?
            puts
            puts "A crazy eight was played! The suit in play is now #{suit}."
        else
            puts
            puts "The top card is currently the #{card['value'].downcase} of #{suit}. "
        end
    end

    def pretty_suits(suit)
        case suit
        when 'SPADES' then pretty_suit = "♠".light_black
        when 'DIAMONDS' then pretty_suit = "♦".red
        when 'HEARTS' then pretty_suit = "♥".magenta
        when 'CLUBS' then pretty_suit = "♣".green
        end
        pretty_suit
    end

    def player_hand(player)
        Hand.where('location = ? AND deck_id = ?', player, deck_id).order(:suit, :value)
    end

    def view_hand(player)
        puts
        puts "You have #{player_hand(player).length} card(s) in your hand: "
        player_hand(player).each do |i| 
            puts "* #{i['value'].downcase} of #{pretty_suits(i['suit'])}; play code: #{i['code'].cyan}"
        end
    end

    def find_card_in_hand(player, card_code)
        player_hand(player).find { |c| c.code == card_code }
    end

    def play_card(player, card_code)
        top = find_top_card
        play_card = find_card_in_hand(player, card_code)
        if play_card.nil?
            puts 'Looks like you are trying to play a card, except what you entered '
            puts 'is not a valid card code or that card is not in your hand.'
        elsif play_card.value == '8'
            view_hand(player)
            suit = eights_are_wild
            move_card_from_hand_to_pile(player, card_code)
            Hand.forget_top_card(deck_id)
            Hand.create(location: 'top', deck_id: deck_id, suit: suit)
            turn_tracker
        elsif top.suit == play_card.suit || top.value == play_card.value
            move_card_from_hand_to_pile(player, card_code)
            turn_tracker
        else
            puts "Looks like that's not a valid card to play. Remember that either the card "
            puts "number or suit needs to match the card on the top of the discard pile."
        end
    end

    def eights_are_wild
        puts
        puts 'Eights are wild! What suit would you like to switch to?'
        suit = STDIN.gets.strip.upcase
        until ['HEARTS', 'SPADES', 'CLUBS', 'DIAMONDS'].include?(suit)
            puts "Mmm, doesn't look like you entered a valid suit. "
            puts "Please [enter] 'spades', 'clubs', 'hearts', or 'diamonds'."
            suit = STDIN.gets.strip.upcase
        end
        puts `clear`
        suit
    end

    def move_card_from_hand_to_pile(player, card_code)
        Hand.forget_top_card(deck_id)
        new_top = find_card_in_hand(player, card_code)
        new_top[:location] = 'top'
        new_top.save
    end

    def computer_turn
        top = find_top_card
        played = false
        if player_hand('computer').nil?
            
        else
            player_hand('computer').each do |i|
                if i['value'] == top['value'] || i['suit'] == top['suit']
                    Hand.forget_top_card(deck_id)
                    i['location'] = 'top'
                    i.save
                    played = true
                    puts "The computer played the #{i['value'].downcase} of #{pretty_suits(i['suit'])}."
                    break
                end
            end
            until played == true
                card = draw_card('computer')
                if card['value'] == top['value'] || card['suit'] == top['suit']
                    Hand.forget_top_card(deck_id)
                    card['location'] = 'top'
                    card.save
                    played = true
                    puts "The computer played the #{card['value'].downcase} of #{pretty_suits(card['suit'])}."
                end
            end
            turn_tracker
        end
    end

    def exit_game_and_delete_deck
        puts 'Are you sure you want to exit and end this game?'
        puts "[enter] 'yes' to confirm."
        input = STDIN.gets.strip.downcase
        case input
        when 'yes'
            Hand.where(deck_id: deck_id).destroy_all
            destroy
        end
    end

end
