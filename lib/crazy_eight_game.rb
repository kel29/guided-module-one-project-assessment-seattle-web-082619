class CrazyEightGame < ActiveRecord::Base

    def new_deck
        deck_info = JSON.parse(RestClient.get("https://deckofcardsapi.com/api/deck/new/shuffle/"))
        self.deck_api_id = deck_info['deck_id']
        update_remaining(deck_info['remaining'])
        save
    end

    def draw_from_api(count)
        deck_info = JSON.parse(RestClient.get("https://deckofcardsapi.com/api/deck/#{deck_api_id}/draw/?count=#{count}"))
        update_remaining(deck_info['remaining'])
        deck_info['cards']
    end

    def deal_start_hand(player)
        draw_from_api(7).each do |card| 
            Hand.create(
                location: player,
                deck_api_id: deck_api_id,
                suit: card['suit'],
                value: card['value'],
                code: card['code']
            )
        end
    end

    def place_start_card
        card_info = draw_from_api(1)[0]
        Hand.create(
            location: 'top',
            deck_api_id: deck_api_id,
            suit: card_info['suit'],
            value: card_info['value'],
            code: card_info['code']
        )
    end

    def draw_card(location)
        card_info = draw_from_api(1)[0]
        card = Hand.create(
            location: location,
            deck_api_id: deck_api_id,
            suit: card_info['suit'],
            value: card_info['value'],
            code: card_info['code']
        )
        display_drawn_card(card_info) unless location == 'computer'
        puts 'There are no more cards to draw. Cats game, everyone loses.'.red if remaining.zero?
        card
    end

    def display_drawn_card(card)
        puts "You drew a #{card['value'].downcase} of #{pretty_suits(card['suit'])}. Its play code is #{card['code'].cyan}."
        puts "There are #{remaining} cards left in the deck."
    end

    def increment_turn_count
        self.turn_count += 1
        save
    end

    def update_remaining(new_remainder)
        self.remaining = new_remainder
        save
    end

    def find_top_card
        Hand.where('location = ? AND deck_api_id = ?', 'top', deck_api_id)[0]
    end

    def view_top_card
        top_card = find_top_card
        suit = pretty_suits(top_card['suit'])
        if top_card.value.nil?
            puts
            puts "A crazy eight was played! The suit in play is now #{suit}."
        else
            puts
            puts "The top card is currently the #{top_card['value'].downcase} of #{suit}. "
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
        Hand.where('location = ? AND deck_api_id = ?', player, deck_api_id).order(:suit, :value)
    end

    def view_hand(player)
        players_hand = player_hand(player)
        puts
        puts "You have #{players_hand.length} card(s) in your hand: "
        players_hand.each do |card| 
            puts "* #{card['value'].downcase} of #{pretty_suits(card['suit'])}; play code: #{card['code'].cyan}"
        end
    end

    def find_card_in_hand(player, card_code)
        player_hand(player).find { |card| card.code == card_code }
    end

    def play_card(player, card_code)
        top_card = find_top_card
        play_card = find_card_in_hand(player, card_code)
        if play_card.nil?
            puts 'Looks like you are trying to play a card, except what you entered '
            puts 'is not a valid card code or that card is not in your hand.'
        elsif play_card.value == '8'
            view_hand(player)
            suit = eights_are_wild
            move_card_from_hand_to_pile(player, card_code)
            Hand.forget_top_card(deck_api_id)
            Hand.create(location: 'top', deck_api_id: deck_api_id, suit: suit)
            increment_turn_count
        elsif top_card.suit == play_card.suit || top_card.value == play_card.value
            move_card_from_hand_to_pile(player, card_code)
            increment_turn_count
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
        Hand.forget_top_card(deck_api_id)
        new_top = find_card_in_hand(player, card_code)
        new_top[:location] = 'top'
        new_top.save
    end

    def computer_turn
        top = find_top_card
        played = false
        player_hand('computer').each do |card|
            if card['value'] == top['value'] || card['suit'] == top['suit']
                Hand.forget_top_card(deck_api_id)
                card['location'] = 'top'
                card.save
                played = true
                puts "The computer played the #{card['value'].downcase} of #{pretty_suits(card['suit'])}."
                break
            end
        end
        until played
            card = draw_card('computer')
            if card['value'] == top['value'] || card['suit'] == top['suit']
                Hand.forget_top_card(deck_api_id)
                card['location'] = 'top'
                card.save
                played = true
                puts "The computer played the #{card['value'].downcase} of #{pretty_suits(card['suit'])}."
            end
        end
        increment_turn_count
    end

    def computer_checks_if_they_can_play
    end

end
