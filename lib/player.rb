class Player < ActiveRecord::Base

    def player_hand(deck_id) #working
        Hand.where("location = ? AND deck_id = ?", self.id.to_s, deck_id)
    end

    def view_hand(deck_id) #working
        puts "You have #{player_hand(deck_id).length} card(s) in your hand: "
        player_hand(deck_id).each { |i| puts "* #{i["value"].downcase} of #{i["suit"].downcase}; play code: #{i["code"]}"}
    end

    def view_top_card(deck_id) #working
        card = Hand.where("location = ? AND deck_id = ?", "top", deck_id)
        puts "The top card is currently the #{card[0]["value"]} of #{card[0]["suit"].downcase}. "
    end

    def draw_a_card(game)
        game.draw_card(self)
        puts "You drew a #{player_hand(game).last["value"].downcase} of #{player_hand(game).last["suit"].downcase}. "
        puts "Its play code is #{player_hand(game).last["code"]}."
    end

    def play_card(deck_id)
        puts "Enter the play code of the card you would like to play: "
        card_code = gets.strip.upcase
        until card_in_hand?(card_code) 
            puts
            puts "Looks like that card is not in your hand."
            puts "As a quick refresher, here is your hand:"
            view_hand
            puts
            puts "Select a card by their play code to play."
            card_code = gets.strip.upcase
        end
        move_card_from_hand_to_pile(card_code)
        puts "You've successfully played a card."
    end

    def card_in_hand?(card_code)
        player_hand.find { |c| c[:code] == card_code }
    end

    def move_card_from_hand_to_pile(card_code)
        forget_top_card
        new_top = self.where(code: card_code)
        new_top[:location] = "top"
    end

end