Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/login', to: 'auth#login'

  get '/users', to: 'users#index'
  post '/users', to: 'users#create'
  get '/profile', to: 'users#profile'

  get '/decks', to: 'decks#index'
  post '/decks', to: 'decks#create'

  get '/cards', to: 'cards#index'
end
