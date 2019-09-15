class Hand < ActiveRecord::Base 

    def self.forget_top_card(deck_api_id)
        old = self.find_by("location = ? AND deck_api_id = ?", "top", deck_api_id)
        old.location = "discard"
        old.save
    end

end
