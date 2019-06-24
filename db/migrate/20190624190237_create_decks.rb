class CreateDecks < ActiveRecord::Migration[5.2]
  def change
    create_table :decks do |t|
      t.integer :user_id
      t.string :name
      t.string :format

      t.timestamps
    end
  end
end
