Rails.application.routes.draw do
  
  post "/admin/users(/:id)/update_user", to: "admin/users#update_user", as: :admin_update_user
  post "/admin/users(/:id)/approve", to: "admin/users#approve_user", as: :admin_approve_user

  get "login(/:token)", to: "home#login", as: :login
  get "logout", to: "home#logout", as: :logout
  get "send_magic_link", to: "home#send_magic_link", as: :send_magic_link
  get "unsubscribe(/:token)", to: "home#unsubscribe", as: :unsubscribe

  namespace :admin do
    resources :users, only: [:index, :show, :update]
    resources :surveys do
      resources :survey_questions
    end
  end

  resources :users, only: [:show, :edit, :update]
  resources :survey_answers, only: [:new, :edit, :update]

  root to: "home#index"
end
