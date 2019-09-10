class CreatePlayerHandTable < ActiveRecord::Migration[5.2]
  def change
    create_table :hands do |t|
      t.text :location
      t.text :deck_id
      t.text :suit
      t.text :value
      t.text :code
    end
  end
end
