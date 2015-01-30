Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  get '/user/any', to: 'users#any'
  
  root 'static_pages#index'

  get '/recipes', to: 'recipes#index'
  get '/recipes/:id', to: 'recipes#show'
  post '/recipes_search', to: 'recipes#search'
  
end
