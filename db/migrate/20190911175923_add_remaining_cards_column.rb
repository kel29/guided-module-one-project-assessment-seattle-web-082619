class AddRemainingCardsColumn < ActiveRecord::Migration[5.2]
  def change
    add_column :crazy_eight_games, :remaining, :integer
  end
end
