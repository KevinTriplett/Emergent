Rails.application.routes.draw do
  
  post "/admin/users(/:id)/patch", to: "admin/users#patch", as: :admin_user_patch
  post "/admin/users(/:id)/approve", to: "admin/users#approve_user", as: :admin_approve_user
  post "/admin/survey_questions(/:id)/patch", to: "admin/survey_questions#patch", as: :admin_survey_question_patch

  get "login(/:token)", to: "home#login", as: :login
  get "logout", to: "home#logout", as: :logout
  get "send_magic_link", to: "home#send_magic_link", as: :send_magic_link
  get "unsubscribe(/:token)", to: "home#unsubscribe", as: :unsubscribe

  namespace :admin do
    resources :users, only: [:index, :show]
    resources :surveys do
      resources :survey_questions, only: [:new, :create, :edit, :update, :destroy]
    end
  end

  resources :users, only: [:show, :edit, :update]
  resources :survey_answers, only: [:new, :edit, :update]

  root to: "home#index"
end
