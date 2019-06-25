class User < ApplicationRecord
  has_secure_password
  has_many :decks
  has_many :favorites
  has_many :favorite_decks, through: :favorites, source: :deck

  validates :username, uniqueness: true
end
