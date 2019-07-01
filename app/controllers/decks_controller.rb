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



      @deck.update(image: random_card_img)

      render json: @deck
    else
      render json: { error: "Something went wrong" }
    end
  end


  private

  def random_card_img(deck)
    if deck.cards.where(quantity: 4)
      random_card = deck.cards.where(quantity: 4)
    else
      random_card = deck.cards
    end

    if random_card.image_uris
      random_card.image_uris["art_crop"]
    else
      "https://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=74250&type=card"
    end
  end

  def deck_params
    params.permit(:user_id, :name, :format)
  end
end
