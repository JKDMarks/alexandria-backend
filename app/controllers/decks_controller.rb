class DecksController < ApplicationController
  def index
    @decks = Deck.all
    render json: @decks
  end

  def create
    @deck = Deck.new(deck_params)

    if @deck.valid?
      @deck.save

      params.permit(:cards).each do |card|
        DeckCard.create(
          deck_id: @deck.id,
          user_id: params.permit(:user_id),
          quantity: card["quantity"]
        )
      end

      render json: @deck
    else
      render json: { error: "Something went wrong" }
    end
  end


  private

  def deck_params
    params.permit(:user_id, :name, :format, :image)
  end
end
