Rails.application.routes.draw do
  
  # sessions for authentication
  get  '/enter', to: 'sessions#create'
  post '/leave', to: 'sessions#destroy'

  post "/admin/users(/:id)/update_user", to: "admin/users#update_user", as: :admin_update_user
  post "/admin/users(/:id)/approve", to: "admin/users#approve_user", as: :admin_approve_user

  namespace :admin do
    resources :users, only: [:index, :show, :update]
  end

  root to: "home#index"
end
