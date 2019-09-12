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

    format_hash = {
      "Commander / EDH" => "commander",
      "Modern*" => "modern",
    }

    if deck_url
      deck_page = Nokogiri::HTML(open(deck_url))

      if deck_url.include?("mtggoldfish.com")
        ############### MTGGOLDFISH ###############
        name = deck_page.css("h2.deck-view-title")[0].children[0].text.strip
        format_string = deck_page.css("div.deck-view-description")[0].text.split("\n").find{|str| str.start_with?("Format:")}
        format = format_string[format_string.index(" ") + 1..-1].downcase
        deck_table_rows = deck_page.css("table.deck-view-deck-table")[0].css("tr")
        cards_array = deck_table_rows.map do |row|
          row.css("td").map{ |td| td.text.strip }[0..1]
        end
        deck_array = cards_array.select{ |arr| arr[0].to_i != 0 || arr[0].start_with?("Sideboard") }.map{|arr| arr.join(" ")}
        split_index = deck_array.index{|str| str.start_with?("Sideboard")}
        mainboard = deck_array[0..(split_index - 1)]
        sideboard = deck_array[(split_index + 1)..-2]
      elsif deck_url.include?("starcitygames.com")
        ############### STARCITYGAMES ###############
        name = deck_page.css("header.deck_title").text
        format = deck_page.css("div.deck_format").text.downcase
        card_uls = deck_page.css("div.cards_col1, div.cards_col2").css("ul")
        mainboard = card_uls[0..-2].css("li").map{|li| li.text}
        sideboard = card_uls.last.css("li").map{|li| li.text}
      elsif deck_url.include?("tappedout.net")
        ############### TAPPEDOUT ###############
        card_h3s_lis = deck_page.css(".row.board-container")[0].css(".board-col").css("h3, li")
        mainboard = []
        sideboard = []
        is_sideboard = false
        card_h3s_lis.each do |node|
          if node.name == "h3"
            ########## h3 ##########
            if node.text.starts_with?("Sideboard")
              is_sideboard = true
            elsif node.text.starts_with?("Commander")
              link = node.parent.css("h3 + ul > a")[0].attributes["href"].value
              card_name = link[link.index("-card/")+"-card/".length..-1]
              card_name = card_name[0..card_name.index("-")-1]
              card = Card.find_by("name ~* ?", card_name)
              if card
                sideboard.push("1 " + card.name)
              end
            end
          else
            ########## li ##########
            quantity = node.css("a")[0].text.to_i.to_s
            card_name = node.css("span").text.strip
            if is_sideboard
              sideboard.push(quantity + " " + card_name)
            else
              mainboard.push(quantity + " " + card_name)
            end
          end
        end
        name = deck_page.css(".featured-card-box ~ h2")[0].text.strip
        format_string = deck_page.css(".featured-card-box ~ p")[0].text.strip
        format_string = format_string[0..format_string.index("\n") - 1]
        format_hash[format_string] ? format = format_hash[format_string] : format = format_string
        if deck_page.css(".commander-img").any?
          image_url = deck_page.css(".commander-img")[0].attributes["src"].value
          image = image_url[image_url.index("//") + 2..-1]
        end
      else
        render json: { error: "Unknown website" }
      end

      decklist = mainboard.join("\n") + "\n\n" + sideboard.join("\n")

      @deck = Deck.create(name: name, format: format, user_id: params[:userId], decklist: decklist)

      deck_colors = []

      return_hash = create_dcs_update_colors(mainboard, @deck, deck_colors)
      deck_colors = return_hash[:deck_colors]

      return_hash = create_dcs_update_colors(sideboard, @deck, deck_colors, true)
      deck_colors = return_hash[:deck_colors]

      deck_colors = deck_colors.uniq

      update_deck_random_img(@deck)

      if !@deck.image
        @deck.update(image: image)
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


  def update_img
    @deck = Deck.find(params[:id])
    update_deck_random_img(@deck)
  end


  private

  def deck_params
    params.permit(:user_id, :name, :format, :image, :decklist)
  end

  def create_dcs_update_colors(cards_arr, deck, deck_colors, is_sideboard = false)
    cards_arr.each_with_index do |card, i|
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

        # card_instance = Card.find_by_name(card_name)
        card_instance = Card.find_by("name ~* ?", "^" + card_name + "$")
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
