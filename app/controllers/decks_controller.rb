class DecksController < ApplicationController
  def index
    @decks = Deck.all
    render json: @decks, include: [:deck_cards, :user]
  end

  def show
    @deck = Deck.find(params[:id])
    render json: @deck, include: [:user, :cards, :deck_cards]
  end

  def create
    @deck = Deck.new(deck_params)

    if @deck.valid?
      @deck.save

      params[:cards].each do |card|
        DeckCard.create(
          deck_id: @deck.id,
          card_id: card["id"],
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
