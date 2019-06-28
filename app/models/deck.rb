class Deck < ApplicationRecord
  belongs_to :user
  has_many :favorite_users, through: :favorites, source: :user
  has_many :deck_cards, dependent: :destroy
  has_many :cards, through: :deck_cards
end
