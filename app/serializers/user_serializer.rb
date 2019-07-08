class UserSerializer < ActiveModel::Serializer
  attributes :id, :username, :favorite_card, :image

  has_many :favorites
end
