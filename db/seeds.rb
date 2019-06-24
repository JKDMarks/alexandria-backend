require 'open-uri'
require 'json'
require 'pry'

def create_cards_from_url(url)
  cards = JSON.parse(open(url).read)

  cards["data"].each do |card|
    if card["set_type"] != "funny"
      type_line = card["type_line"].split(" — ")

      Card.create({
        scryfall_id: card["id"],
        name: card["name"],
        image_uris: card["image_uris"],
        mana_cost: card["mana_cost"],
        cmc: card["cmc"],
        oracle_text: card["oracle_text"],
        colors: card["colors"],
        color_identity: card["color_identity"],
        legalities: card["legalities"],
        prices: card["prices"],
        types: type_line[0].split,
        subtypes: type_line[1].split
      })
    end

    puts card["name"]
  end

  if cards["has_more"]
    create_cards_from_url(cards["next_page"])
  end
end

url = "https://api.scryfall.com/cards/search?q=t:%22legendary%20creature%22"

create_cards_from_url(url)

"hello"
