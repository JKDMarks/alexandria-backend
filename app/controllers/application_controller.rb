class ApplicationController < ActionController::API
  def user_payload(user)
    { user_id: user.id }
  end

  def encode_token(user)
    JWT.encode user_payload(user), 'power10', 'HS256'
  end

  def update_deck_random_img(deck)
    nonland_quantity_4_cards = deck.deck_cards.where(quantity: 4, sideboard: false).map{ |deck_card| deck_card.card }.select{ |card| card.types.exclude?("Land") }
    random_card = nonland_quantity_4_cards.sample

    if random_card && random_card.image_uris && random_card.image_uris.any?
      art_crop = random_card.image_uris["art_crop"]
      if art_crop
        deck.update(image: art_crop)
      end
    end
  end
end
