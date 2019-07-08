class ChangeUserFavCardIdToFavCard < ActiveRecord::Migration[5.2]
  def change
    change_column :users, :favorite_card_id, :string
    rename_column :users, :favorite_card_id, :favorite_card
  end
end
