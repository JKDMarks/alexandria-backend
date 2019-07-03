class DecksController < ApplicationController
  def index
    @decks = Deck.order(:updated_at)
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

  def create_from_decklist
    @deck = Deck.new(deck_params)

    if @deck.valid?
      @deck.save
      decklist = params[:decklist].split("\n")
      split_index = decklist.index("")
      mainboard = decklist[0..(split_index - 1)]
      sideboard = decklist[(split_index + 1)..-1]

      mainboard.each do |card|
        card = card.split(" ", 2)
        quantity = card[0].to_i
        card_name = card[1]

        if card_name.scan(/ \/ /).count == 1
          card_name = card_name.sub(" / ", " // ")
        elsif card_name.count("/") == 1
          card_name = card_name.sub("/", " // ")
        end

        card_instance = Card.find_by("name ~* ?", card_name)

        if quantity != 0 && card_instance
          DeckCard.create(
            card: card_instance,
            deck: @deck,
            quantity: quantity
          )
        end
      end

      sideboard.each do |card|
        card = card.split(" ", 2)
        quantity = card[0].to_i
        card_name = card[1]

        if card_name.scan(/ \/ /).count == 1
          card_name = card_name.sub(" / ", " // ")
        elsif card_name.count("/") == 1
          card_name = card_name.sub("/", " // ")
        end

        card_instance = Card.find_by("name ~* ?", card_name)

        if quantity != 0 && card_instance
          dc = DeckCard.create(
            card: card_instance,
            deck: @deck,
            quantity: quantity,
            sideboard: true
          )
        end
      end

      render json: @deck
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
        quantity: card["quantity"],
        sideboard: card["sideboard"]
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

  def deck_params
    params.permit(:user_id, :name, :format)
  end
end
