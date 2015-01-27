Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations', sessions: 'users/sessions' }

  get '/user/any', to: 'users#any'
  
  root 'static_pages#index'

  resources :recipes
end
