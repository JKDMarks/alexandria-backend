class AddDecklistToDeck < ActiveRecord::Migration[5.2]
  def change
    add_column :decks, :decklist, :string
  end
end
