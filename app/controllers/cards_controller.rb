require 'open-uri'
require 'json'

class CardsController < ApplicationController
  def index
    # @cards = Card.all
    @cards = Card.order(:name).first(50)
    render json: @cards
  end

  def by_format
    @cards = Card.order(:name).first(50)

    cards_by_format = @cards.select do |card|
      card.legalities[params[:format]] === "legal"
    end

    render json: cards_by_format
  end

  # def update_image
  #   img = params[:imageUrl]
  #   img = img[0..img.index("?")-1]
  #   card = Card.find_by("image_uris ~* ?", img)
  #
  #   updated_card = JSON.parse(open("https://api.scryfall.com/cards/#{card.scryfall_id}").read)
  #
  #   card.update(image_uris: updated_card["image_uris"])
  # end
end
