Rails.application.routes.draw do
  
  get  "/admin/users/:token/token/:command", to: "admin/users#token_command", as: :admin_user_token
  post "/admin/users/:token/patch", to: "admin/users#patch", as: :admin_user_patch
  post "/admin/users/:token/approve", to: "admin/users#approve_user", as: :admin_approve_user
  post "/admin/survey_questions/:id/patch", to: "admin/survey_questions#patch", as: :admin_survey_question_patch

  get "login/:token", to: "home#login", as: :login
  get "logout", to: "home#logout", as: :logout
  get "send_magic_link", to: "home#send_magic_link", as: :send_magic_link
  get "unsubscribe/:token", to: "home#unsubscribe", as: :unsubscribe
  get "user_search", to: "admin/users#search", as: :user_search
  
  get "survey/:token(/:position)", to: "survey_invites#show", as: :survey

  namespace :admin do
    resources :users, param: :token, only: [:index, :show]
    resources :surveys do
      resources :survey_questions, only: [:new, :create, :edit, :update, :destroy]
      resources :survey_invites, only: [:new, :create]
    end
  end

  resources :users, param: :token, only: [:show, :edit, :update]

  root to: "home#index"
end
