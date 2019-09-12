class Player < ActiveRecord::Base

    def player_hand(deck_id)
        Hand.where('location = ? AND deck_id = ?', id.to_s, deck_id).order(:suit, :value)
    end

    def view_hand(deck_id)
        puts
        puts "You have #{player_hand(deck_id).length} card(s) in your hand: "
        player_hand(deck_id).each do |i| 
            puts "* #{i['value'].downcase} of #{pretty_suits(i['suit'])}; play code: #{i['code'].cyan}"
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

    def find_card_in_hand(deck_id, card_code)
        player_hand(deck_id).find { |c| c.code == card_code }
    end

    def find_top_card(deck_id)
        Hand.where('location = ? AND deck_id = ?', 'top', deck_id)
    end

    def view_top_card(deck_id)
        card = find_top_card(deck_id)[0]
        suit = pretty_suits(card['suit'])
        if card.value.nil?
            puts
            puts "A crazy eight was played! The suit in play is now #{suit}."
        else
            puts
            puts "The top card is currently the #{card['value'].downcase} of #{suit}. "
        end
    end

    def play_card(game, card_code)
        top = find_top_card(game.deck_id)[0]
        play_card = find_card_in_hand(game.deck_id, card_code)
        if play_card.nil?
            puts 'Looks like you are trying to play a card, except that '
            puts 'is not a valid card code or that card is not in your hand.'
        elsif play_card.value == '8'
            view_hand(game.deck_id)
            suit = eights_are_wild
            move_card_from_hand_to_pile(game.deck_id, card_code)
            Hand.forget_top_card(game.deck_id)
            Hand.create(location: 'top', deck_id: game.deck_id, suit: suit)
            game.turn_tracker
        elsif top.suit == play_card.suit || top.value == play_card.value
            move_card_from_hand_to_pile(game.deck_id, card_code)
            game.turn_tracker
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

    def move_card_from_hand_to_pile(deck_id, card_code)
        Hand.forget_top_card(deck_id)
        new_top = find_card_in_hand(deck_id, card_code)
        new_top[:location] = 'top'
        new_top.save
    end

    def exit_game_and_delete_deck(game)
        puts 'Are you sure you want to exit and end this game?'
        puts "[enter] 'yes' to confirm."
        input = STDIN.gets.strip.downcase
        case input
        when 'yes'
            Hand.where(deck_id: game.deck_id).destroy_all
            game.destroy
        end
    end

end