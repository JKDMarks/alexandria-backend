class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :favorite_card_id, :image

  has_many :favorites
end
