class DeckSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :name, :image, :format, :created_at, :colors, :decklist

  has_many :deck_cards
  has_many :cards
  belongs_to :user

  class UserSerializer < ActiveModel::Serializer
    attributes :id, :username, :image
  end
end
