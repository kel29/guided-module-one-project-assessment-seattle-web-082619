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
        # validate_card_is_playable(deck_id, card_code)
        # move_card_from_hand_to_pile(card_code)
        puts "You've successfully played a card."
    end

    def find_card_in_hand(deck_id, card_code)
        player_hand(deck_id).find { |c| c.code == card_code }
    end

    def card_not_in_hand_error_loop(deck_id, card_code)
        until find_card_in_hand(deck_id, card_code)
            puts
            puts "Looks like that card is not in your hand."
            puts "As a quick refresher, here is your hand:"
            view_hand(deck_id)
            puts
            puts "Select a card by their play code to play."
            card_code = STDIN.gets.strip.upcase
        end
    end

    # def validate_card_is_playable(deck_id, card_code)
    #     top = find_top_card(deck_id)
    #     play_card = find_card_in_hand(deck_id, card_code)
    #     until top.suit == play_card.suit || top.value == play_card.value || play_card.value == "8"
    #         puts "Looks like that's not a valid card to play."
    #         puts "Remember, either the card number or suit needs to "
    #         puts "match the card on the top of the discard pile. "
    #         view_top_card(deck_id)
    #     end
    # end

    def move_card_from_hand_to_pile(card_code)
        forget_top_card
        new_top = self.where(code: card_code)
        new_top[:location] = "top"
    end

end