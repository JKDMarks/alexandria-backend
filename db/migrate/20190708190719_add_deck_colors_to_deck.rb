class AddDeckColorsToDeck < ActiveRecord::Migration[5.2]
  def change
    add_column :decks, :colors, :string
  end
end
