Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  get '/user/any', to: 'users#any'
  # get '/user/:id/bookmarks', to: 'users#bookmarks'
  post '/bookmarks/:recipe_id', to: 'users#add_bookmark'
  delete '/bookmarks/:recipe_id', to: 'users#remove_bookmark'
  
  root 'static_pages#index'

  get '/recipes/:id', to: 'recipes#show'
  post '/recipes', to: 'recipes#create'
  post '/recipes/search', to: 'recipes#search'
  post '/recipes/search_count', to: 'recipes#search_count'
  
end
