class Player < ActiveRecord::Base

    def player_hand(deck_id) #working
        # binding.pry
        Hand.where("location = ? AND deck_id = ?", self.id.to_s, deck_id)
    end

    def view_hand(deck_id) #working
        puts "You have #{player_hand(deck_id).length} card(s) in your hand: "
        player_hand(deck_id).each { |i| puts "* #{i["value"].downcase} of #{i["suit"].downcase}; play code: #{i["code"]}"}
    end

    def find_top_card(deck_id) #working
        Hand.where("location = ? AND deck_id = ?", "top", deck_id)
    end

    def view_top_card(deck_id) #working
        card = find_top_card(deck_id)[0]
        puts "The top card is currently the #{card["value"]} of #{card["suit"].downcase}. "
    end

    def play_card(deck_id)
        puts "Enter the play code of the card you would like to play: "
        card_code = STDIN.gets.strip.upcase
        card_not_in_hand_error_loop(deck_id, card_code)
        validate_card_is_playable(deck_id, card_code)
        move_card_from_hand_to_pile(deck_id, card_code)
        puts "You've successfully played a card."
    end

    def find_card_in_hand(deck_id, card_code)
        player_hand(deck_id).find { |c| c.code == card_code }
    end

    def card_not_in_hand_error_loop(deck_id, card_code)
        until find_card_in_hand(deck_id, card_code)
            puts
            puts "Looks like that is not a valid card code or that card is "
            puts "not in your hand. As a quick refresher, here is your hand:"
            view_hand(deck_id)
            puts
            puts "Select a card to play by entering their play code:"
            card_code = STDIN.gets.strip.upcase
        end
    end

    def validate_card_is_playable(deck_id, card_code) #doesn't work if someone loops too many times
        top = find_top_card(deck_id)[0]
        play_card = find_card_in_hand(deck_id, card_code)
        # binding.pry
        until top.suit == play_card.suit || top.value == play_card.value || play_card.value == "8"
            puts "Looks like that's not a valid card to play."
            # puts "First, you can only play cards that are in you hand. "
            # view_hand(deck_id)
            puts "Then, remember that either the card number or suit needs "
            puts "to match the card on the top of the discard pile. "
            view_top_card(deck_id)
            puts "Please enter a valid card code: "
            card_code = STDIN.gets.strip.upcase
            # binding.pry
            card_not_in_hand_error_loop(deck_id, card_code)
            # binding.pry
            play_card = find_card_in_hand(deck_id, card_code)
        end
    end

    def move_card_from_hand_to_pile(deck_id, card_code)
        Hand.forget_top_card(deck_id)
        new_top = find_card_in_hand(deck_id, card_code)
        new_top.location = "top"
        new_top.save
    end

end