class Hand < ActiveRecord::Base 

    def self.forget_top_card(deck_id)
        old = self.find_by("location = ? AND deck_id = ?", "top", deck_id)
        old.location = "discard"
        old.save
    end

end