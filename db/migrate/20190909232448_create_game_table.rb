class CreateGameTable < ActiveRecord::Migration[5.2]
  def change
    create_table :crazy_eight_games do |t|
      t.text :deck_id
      t.integer :player_id
    end
  end
end
