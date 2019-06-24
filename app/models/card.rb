class Card < ApplicationRecord
  serialize :image_uris, Hash
  serialize :colors, Array
  serialize :color_identity, Array
  serialize :legalities, Hash
  serialize :prices, Hash
  serialize :types, Array
  serialize :subtypes, Array

  has_many :deck_cards
  has_many :decks, through: :deck_cards

  validates :scryfall_id, uniqueness: true
end
