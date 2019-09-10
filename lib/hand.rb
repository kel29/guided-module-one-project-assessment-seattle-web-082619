class Hand < ActiveRecord::Base 

    def forget_top_card
        old = self.where(location: "top")
        old[:location] = "discard"
    end

end