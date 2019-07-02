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
end
