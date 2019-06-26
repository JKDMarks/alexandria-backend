require 'open-uri'
require 'json'
require 'pry'

def create_cards_from_url(url)
  cards = JSON.parse(open(url).read)

  cards["data"].each do |card|
    if card["set_type"] != "funny"
      type_line = card["type_line"].split(" — ")

      Card.create({
        id: card["id"],
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

# create_cards_from_url(url)

(1..3).to_a.each do |n|
  User.create(
    username: "jeff#{n}",
    password: "jeff",
    favorite_card_id: Card.all.sample.id,
    image: Card.all.sample.image_uris["art_crop"]
  )
end

archetypes = [
  ["Mono Red", "standard"],
  ["Esper Control", "standard"],
  ["4C Dreadhorde", "standard"],
  ["Esper Hero", "standard"],
  ["UR Phoenix", "modern"],
  ["5C Humans", "modern"],
  ["GDS", "modern"],
  ["Tron, Wow F**k", "modern"],
  ["Grixis Delver", "legacy"],
  ["D&T", "legacy"],
  ["Show and Tell", "legacy"],
  ["Nic Fit", "legacy"],
  ["Esper PO", "vintage"],
  ["Shops", "vintage"],
]

archetypes.each do |archetype|
  deck = Deck.create(
    user: User.all.sample,
    name: archetype[0],
    format: archetype[1],
    image: Card.all.sample.image_uris["art_crop"]
  )
  
  5.times do
    DeckCard.create(deck: deck, card: Card.all.sample, quantity: rand(1..4))
  end
end
