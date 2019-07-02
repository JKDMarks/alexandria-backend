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

      card = Card.find(params[:image])

      if card &&card.image_uris.any?
        card_image = card.image_uris["art_crop"]
      else
        card_image = Card.find_by_name("Black Lotus").image_uris["art_crop"]
      end

      @deck.update(image: card_image)

      render json: @deck
    else
      render json: { error: "Something went wrong" }
    end
  end

  def update
    @deck = Deck.find(params[:id])
    @deck.update(params.permit(:name))
    card_image = Card.find(params[:image]).image_uris["art_crop"]
    @deck.update(image: card_image)

    @deck.deck_cards.destroy_all

    params[:cards].each do |card|
      DeckCard.create(
        deck_id: @deck.id,
        card_id: card["id"],
        quantity: card["quantity"]
      )
    end

    render json: @deck
  end

  def delete
    Deck.find(params[:id]).destroy
    @decks = Deck.all
    render json: @decks, include: []
  end

  private

  # def random_card_img(deck)
  #   if deck.deck_cards.where(quantity: 4).any?
  #     deck_cards = deck.deck_cards.where(quantity: 4)
  #   else
  #     deck_cards = deck.deck_cards
  #   end
  #
  #   random_card = deck_cards.sample.card
  #
  #   if random_card.image_uris.any?
  #     random_card.image_uris["art_crop"]
  #   else
  #     "https://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=74250&type=card"
  #   end
  # end

  def deck_params
    params.permit(:user_id, :name, :format)
  end
end
