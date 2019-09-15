class ChangeColumnNameFromDeckIdToDeckApiId < ActiveRecord::Migration[5.2]
  def change
    rename_column :hands, :deck_id, :deck_api_id
  end
end
