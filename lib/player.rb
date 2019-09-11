class Player < ActiveRecord::Base

    def player_hand(deck_id)
        # binding.pry
        Hand.where('location = ? AND deck_id = ?', id.to_s, deck_id).order(:suit, :value)
    end

    def view_hand(deck_id)
        puts "You have #{player_hand(deck_id).length} card(s) in your hand: "
        player_hand(deck_id).each { |i| puts "* #{i['value'].downcase} of #{i['suit'].downcase}; play code: #{i['code']}"}
    end

    def find_card_in_hand(deck_id, card_code)
        player_hand(deck_id).find { |c| c.code == card_code }
    end

    def find_top_card(deck_id)
        Hand.where('location = ? AND deck_id = ?', 'top', deck_id)
    end

    def view_top_card(deck_id)
        card = find_top_card(deck_id)[0]
        puts "The top card is currently the #{card['value'].downcase} of #{card['suit'].downcase}. "
    end

    def play_card(deck_id)
        puts 'Enter the play code of the card you would like to play: '
        card_code = STDIN.gets.strip.upcase
        top = find_top_card(deck_id)[0]
        play_card = find_card_in_hand(deck_id, card_code)
        if play_card.nil?
            puts 'Looks like that is not a valid card code or that card is not in your hand.'
        elsif play_card.value == '8'
            suit = eights_are_wild
            move_card_from_hand_to_pile(deck_id, card_code)
            Hand.forget_top_card(deck_id)
            Hand.create('location = ?, deck_id = ?, suit = ?', 'top', deck_id, suit)
        elsif top.suit == play_card.suit || top.value == play_card.value
            move_card_from_hand_to_pile(deck_id, card_code)
            puts "You've successfully played your card."
        else
            puts "Looks like that's not a valid card to play. Remember that either the card "
            puts "number or suit needs to match the card on the top of the discard pile."
        end
    end

    def eights_are_wild
        puts 'Eights are wild! What suit would you like to switch to?'
        suit = STDIN.gets.strip.upcase
        until ['HEARTS', 'SPADES', 'CLUBS', 'DIAMONDS'].include?(suit)
            puts "Mmm, doesn't look like you entered a valid suit. "
            puts "Please [enter] 'spades', 'clubs', 'hearts', or 'diamonds'."
            suit = STDIN.gets.strip.upcase
            
        end
        suit
    end

    def move_card_from_hand_to_pile(deck_id, card_code)
        Hand.forget_top_card(deck_id)
        new_top = find_card_in_hand(deck_id, card_code)
        new_top[:location] = 'top'
        new_top.save
    end

    def exit_game_and_delete_deck(game)
        Hand.where(deck_id: game.deck_id).destroy_all
        game.destroy
    end

end