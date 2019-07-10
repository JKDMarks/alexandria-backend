class DecksController < ApplicationController
  def index
    @decks = Deck.order(:updated_at)
    render json: @decks, include: [:deck_cards, :user]
  end


  def by_format
    @decks = Deck.all

    decks_by_format = @decks.select do |deck|
      deck.format === params[:format]
    end

    render json: decks_by_format
  end


  def show
    @deck = Deck.find(params[:id])
    render json: @deck, include: [:user, :cards, :deck_cards]
  end


  def create
    @deck = Deck.new(deck_params)

    if @deck.valid?
      @deck.save
      deck_colors = []
      decklist = params[:decklist].split("\n")
      split_index = decklist.index("")
      mainboard = decklist[0..(split_index - 1)]
      sideboard = decklist[(split_index + 1)..-1]

      return_hash = create_dcs_update_colors_and_decklist(mainboard, @deck, deck_colors, decklist)
      deck_colors = return_hash[:deck_colors]
      decklist = return_hash[:decklist]

      return_hash = create_dcs_update_colors_and_decklist(sideboard, @deck, deck_colors, decklist, true)
      deck_colors = return_hash[:deck_colors]
      decklist = return_hash[:decklist]

      deck_colors = deck_colors.uniq
      @deck.update(colors: deck_colors)

      render json: @deck
    end
  end


  def update
    @deck = Deck.find(params[:id])
    @deck.update(params.permit(:name, :format, :image, :decklist))

    @deck.deck_cards.destroy_all

    deck_colors = []
    decklist = params[:decklist].split("\n")
    split_index = decklist.index("")
    mainboard = decklist[0..(split_index - 1)]
    sideboard = decklist[(split_index + 1)..-1]

    return_hash = create_dcs_update_colors_and_decklist(mainboard, @deck, deck_colors, decklist)
    deck_colors = return_hash[:deck_colors]
    decklist = return_hash[:decklist]

    return_hash = create_dcs_update_colors_and_decklist(sideboard, @deck, deck_colors, decklist, true)
    deck_colors = return_hash[:deck_colors]
    decklist = return_hash[:decklist]

    deck_colors = deck_colors.uniq
    @deck.update(colors: deck_colors)

    render json: @deck
  end


  def delete
    Deck.find(params[:id]).destroy
    @decks = Deck.all
    render json: @decks, include: []
  end



  private

  def deck_params
    params.permit(:user_id, :name, :format, :image, :decklist)
  end

  def create_dcs_update_colors_and_decklist(cards_arr, deck, deck_colors, decklist, is_sideboard = false)
    cards_arr.each do |card|
      # puts "==============================" + card + "=============================="
      card = card.split(" ", 2)
      quantity = card[0].to_i
      card_name = card[1]

      if card_name.scan(/ \/ /).count == 1
        card_name = card_name.sub(" / ", " // ")
      elsif card_name.count("/") == 1
        card_name = card_name.sub("/", " // ")
      end

      card_name = card_name.sub("’", "'")

      card_instance = Card.find_by("name ~* ?", "^" + card_name)

      if quantity != 0 && card_instance
        DeckCard.create(
          card: card_instance,
          deck: deck,
          quantity: quantity,
          sideboard: is_sideboard
        )

        if card_instance.mana_cost.exclude?("P") && card_instance.mana_cost.exclude?("/")
          deck_colors = deck_colors + card_instance.colors
        end
      # else
      #   byebug
      end
    end

    return { deck_colors: deck_colors, decklist: decklist }
  end
end

# UPDATE DECK COLORS
# Deck.all.each do |deck|
#   deck.cards.each do |card|
#     if card.mana_cost && card.mana_cost.exclude?("P") && card.mana_cost.exclude?("/")
#       card.colors.each do |color|
#         if !deck.colors.include?(color)
#           deck.update(colors: deck.colors + [color])
#         end
#       end
#     end
#   end
# end
