Rails.application.routes.draw do
  
  post "/greeters/users(/:id)/update_user", to: "greeters/users#update_user", as: :greeter_update_user
  post "/greeters/users(/:id)/approve", to: "greeters/users#approve_user", as: :greeter_approve_user

  get "/admin/users(/:search_terms)", to: "admin/users#search", as: :admin_search_users

  get "login(/:token)", to: "home#login", as: :login
  get "logout", to: "home#logout", as: :logout
  get "send_magic_link", to: "home#send_magic_link", as: :send_magic_link
  get "unsubscribe(/:token)", to: "home#unsubscribe", as: :unsubscribe

  namespace :admin do
    resources :users, only: [:index, :edit, :update]
    resources :roles, only: [:index, :edit, :update]
  end

  namespace :greeters do
    resources :users, only: [:index, :edit, :update]
  end

  resources :users, param: :token, only: [:show, :edit, :update]

  root to: "home#index"
end
