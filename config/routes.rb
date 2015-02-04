Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  get '/user/any', to: 'users#any'
  get '/user/:id/bookmarks', to: 'users#bookmarks'
  post '/user/:id/bookmarks', to: 'users#bookmarks'
  
  root 'static_pages#index'

  get '/recipes/:id', to: 'recipes#show'
  post '/recipes/search', to: 'recipes#search'
  post '/recipes/search_count', to: 'recipes#search_count'
  
end
