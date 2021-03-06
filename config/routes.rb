Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/login', to: 'auth#login'

  get '/users', to: 'users#index'
  post '/users', to: 'users#create'
  get '/users/:id', to: 'users#show'
  patch '/users/:id', to: 'users#update'
  get '/profile', to: 'users#profile'

  get '/decks', to: 'decks#index'
  get '/decks/format/:format', to: 'decks#by_format'
  get '/decks/:id', to: 'decks#show'
  post '/decks', to: 'decks#create'
  post '/decks/url', to: 'decks#create_from_url'
  get '/decks/update_img/:id', to: 'decks#update_img'
  patch '/decks/:id', to: 'decks#update'
  delete '/decks/:id', to: 'decks#delete'

  get '/cards', to: 'cards#index'
  get '/cards/:format', to: 'cards#by_format'
  post '/update_image', to: 'cards#update_image'

  post '/favorites', to: 'favorites#create'
  delete '/favorites/:user_id/:deck_id', to: 'favorites#destroy'
end
