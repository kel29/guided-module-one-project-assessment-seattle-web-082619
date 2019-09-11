class Player < ActiveRecord::Base

    def player_hand(deck_id) #working
        # binding.pry
        Hand.where("location = ? AND deck_id = ?", self.id.to_s, deck_id).order(:value, :suit)
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
        top = find_top_card(deck_id)[0]
        play_card = find_card_in_hand(deck_id, card_code)
        if play_card.nil?
            puts
            puts "Looks like that is not a valid card code or "
            puts "that card is not in your hand. "
        elsif play_card.value == "8"
            puts "Eights are wild! What suit would you like to switch to?"
            suit = STDIN.gets.strip.upcase
            until suit == "HEARTS" || suit == "SPADES" || suit == "CLUBS" || suit == "DIAMONDS"
                puts "Mmm, doesn't look like you entered a valid suit. "
                puts "Please [enter] 'spades', 'clubs', 'hearts', or 'diamonds'."
                suit = STDIN.gets.strip.upcase
            end
            move_card_from_hand_to_pile(deck_id, card_code)
            Hand.forget_top_card(deck_id)
            Hand.create(location: "top", deck_id: deck_id, suit: suit)
        elsif top.suit == play_card.suit || top.value == play_card.value
            move_card_from_hand_to_pile(deck_id, card_code)
            puts "You've successfully played a card."
        else
            puts "Looks like that's not a valid card to play."
            puts "Remember that either the card number or suit needs "
            puts "to match the card on the top of the discard pile. "
        end
    end

    def find_card_in_hand(deck_id, card_code)
        player_hand(deck_id).find { |c| c.code == card_code }
    end

    def move_card_from_hand_to_pile(deck_id, card_code)
        Hand.forget_top_card(deck_id)
        new_top = find_card_in_hand(deck_id, card_code)
        new_top[:location] = "top"
        new_top.save
    end

end