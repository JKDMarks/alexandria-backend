class CardsController < ApplicationController
  def index
    # @cards = Card.all
    @cards = Card.first(50)
    render json: @cards
  end
end
