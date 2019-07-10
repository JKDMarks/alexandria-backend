require 'open-uri'
require 'nokogiri'

class DecksController < ApplicationController
  def index
    @decks = Deck.order(:created_at)
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

      return_hash = create_dcs_update_colors(mainboard, @deck, deck_colors)
      deck_colors = return_hash[:deck_colors]

      return_hash = create_dcs_update_colors(sideboard, @deck, deck_colors, true)
      deck_colors = return_hash[:deck_colors]

      deck_colors = deck_colors.uniq
      @deck.update(colors: deck_colors)

      render json: @deck
    end
  end


  def create_from_url
    deck_url = params[:deckURL]

    if deck_url
      deck_page = Nokogiri::HTML(open(deck_url))

      if deck_url.include?("www.mtggoldfish.com")
        name = deck_page.css("h2.deck-view-title")[0].children[0].text.strip
        format_string = deck_page.css("div.deck-view-description")[0].text.split("\n").find{|str| str.start_with?("Format:")}
        format = format_string[format_string.index(" ") + 1..-1].downcase
        # image_style = deck_page.css("div.card-image-tile")[0].attributes["style"].content
        # image = image_style[image_style.index("\(\'")+2..image_style.index("\'\)\;")-1]
        deck_table_rows = deck_page.css("table.deck-view-deck-table")[0].css("tr")
        cards_array = deck_table_rows.map do |row|
          row.css("td").map{ |td| td.text.strip }[0..1]
        end
        deck_array = cards_array.select{ |arr| arr[0].to_i != 0 || arr[0].start_with?("Sideboard") }.map{|arr| arr.join(" ")}
        split_index = deck_array.index{|str| str.start_with?("Sideboard")}
        mainboard = deck_array[0..(split_index - 1)]
        sideboard = deck_array[(split_index + 1)..-2]
      elsif deck_url.include?("www.starcitygames.com")
        name = deck_page.css("header.deck_title").text
        format = deck_page.css("div.deck_format").text.downcase
        card_uls = deck_page.css("div.cards_col1, div.cards_col2").css("ul")
        mainboard = card_uls[0..-2].css("li").map{|li| li.text}
        sideboard = card_uls.last.css("li").map{|li| li.text}
      else
        render json: { error: "Unknown website" }
      end

      @deck = Deck.create(name: name, format: format, user_id: params[:userId])

      deck_colors = []

      return_hash = create_dcs_update_colors(mainboard, @deck, deck_colors)
      deck_colors = return_hash[:deck_colors]

      return_hash = create_dcs_update_colors(sideboard, @deck, deck_colors, true)
      deck_colors = return_hash[:deck_colors]

      deck_colors = deck_colors.uniq
      nonland_quantity_4_cards = @deck.deck_cards.where(quantity: 4, sideboard: false).map{ |deck_card| deck_card.card }.select{ |card| card.types.exclude?("Land") }
      random_card = nonland_quantity_4_cards.sample

      if random_card.image_uris.any?
        art_crop = random_card.image_uris["art_crop"]
        if art_crop
          @deck.update(image: art_crop)
        end
      end

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

    return_hash = create_dcs_update_colors(mainboard, @deck, deck_colors)
    deck_colors = return_hash[:deck_colors]

    return_hash = create_dcs_update_colors(sideboard, @deck, deck_colors, true)
    deck_colors = return_hash[:deck_colors]

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

  def create_dcs_update_colors(cards_arr, deck, deck_colors, is_sideboard = false)
    cards_arr.each_with_index do |card, i|
      # puts "==============================" + card + "=============================="
      card = card.split(" ", 2)
      quantity = card[0].to_i
      card_name = card[1]

      if card_name
        if card_name.scan(/ \/ /).count == 1
          card_name = card_name.sub(" / ", " // ")
        elsif card_name.count("/") == 1
          card_name = card_name.sub("/", " // ")
        end

        card_name = card_name.sub("’", "'")

        card_instance = Card.find_by("name ~* ?", "^" + card_name)
      else
        card_instance = nil
      end



      if quantity != 0 && card_instance
        DeckCard.create(
          card: card_instance,
          deck: deck,
          quantity: quantity,
          sideboard: is_sideboard
        )

        if card_instance.mana_cost && card_instance.mana_cost.exclude?("P") && card_instance.mana_cost.exclude?("/")
          deck_colors = deck_colors + card_instance.colors
        end
      # else
      #   byebug
      end
    end

    return { deck_colors: deck_colors }
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
