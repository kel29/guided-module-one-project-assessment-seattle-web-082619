class ChangeColumnNameFromDeckIdToDeckApiIdInGameTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :crazy_eight_games, :deck_id, :deck_api_id
  end
end
