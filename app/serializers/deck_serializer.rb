class DeckSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :name, :format

  has_many :deck_cards
end
