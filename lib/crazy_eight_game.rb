require 'JSON'
require 'rest-client'
require 'pry'

class CrazyEightGame < ActiveRecord::Base


    def new_deck
        puts "Grabbing a new deck..."
        new_deck_response = RestClient.get("https://deckofcardsapi.com/api/deck/new/shuffle/")
        new_deck_hash = JSON.parse(new_deck_response)
        self.deck_id = new_deck_hash["deck_id"]
        self.save
        @deck_id
    end

    def deal_start_hand(player)
        puts "Dealing the start hand..."
        start_hand_response = RestClient.get("https://deckofcardsapi.com/api/deck/#{self.deck_id}/draw/?count=7")
        start_hand_hash = JSON.parse(start_hand_response)
        start_hand_hash["cards"].each do |c| 
            Hand.create(location: player[:player_id], deck_id: self.deck_id, suit: c["suit"], value: c["value"], code: c["code"])
        end
    end

    def place_start_card
        puts "Placing the first card..."
        card_response = RestClient.get("https://deckofcardsapi.com/api/deck/#{self.deck_id}/draw/?count=1")
        card_hash = JSON.parse(card_response)["cards"][0]
        start = Hand.create(location: "top", deck_id: self.deck_id, suit: card_hash["suit"], value: card_hash["value"], code: card_hash["code"])
        puts "The first card in play is a #{start["value"].downcase} of #{start["suit"].downcase}."
        start
    end


    def draw_card(player)
        new_card_response = RestClient.get("https://deckofcardsapi.com/api/deck/#{self.deck_id}/draw/?count=1")
        new_card_hash = JSON.parse(new_card_response)["cards"][0]
        new_card = Hand.create(location: player[:player_id], deck_id: self.deck_id, suit: new_card_hash["suit"], value: new_card_hash["value"], code: new_card_hash["code"])
        puts "You drew a #{new_card["value"].downcase} of #{new_card["suit"].downcase}."
        new_card
    end

end