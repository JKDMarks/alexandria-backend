class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.string :scryfall_id
      t.string :name
      t.string :image_uris
      t.string :mana_cost
      t.integer :cmc
      t.string :oracle_text
      t.string :colors
      t.string :color_identity
      t.string :legalities
      t.string :prices
      t.string :types
      t.string :subtypes
    end
  end
end
