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
  post '/decklist', to: 'decks#create_from_decklist'
  patch '/decks/:id', to: 'decks#update'
  delete '/decks/:id', to: 'decks#delete'

  get '/cards', to: 'cards#index'
  get '/cards/:format', to: 'cards#by_format'

  post '/favorites', to: 'favorites#create'
  delete '/favorites/:user_id/:deck_id', to: 'favorites#destroy'
end
