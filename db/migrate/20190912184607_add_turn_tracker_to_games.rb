class AddTurnTrackerToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :crazy_eight_games, :turn_count, :integer
  end
end
