Rails.application.routes.draw do
  
  post "/greeters/users(/:id)/update_user", to: "greeters/users#update_user", as: :greeter_update_user
  post "/greeters/users(/:id)/approve", to: "greeters/users#approve_user", as: :greeter_approve_user

  get "/admin/users(/:search_terms)", to: "admin/users#search", as: :admin_search_users
  get  "/admin/users/:token/token/:command", to: "admin/users#token_command", as: :admin_user_token
  post "/admin/users/:token/patch", to: "admin/users#patch", as: :admin_user_patch
  post "/admin/users/:token/approve", to: "admin/users#approve_user", as: :admin_approve_user
  
  get  "/admin/surveys/:id/test", to: "admin/surveys#test", as: :admin_survey_test
  get  "/admin/surveys/:id/notes/new", to: "admin/surveys#new_note", as: :new_admin_survey_note
  get  "/admin/surveys/:id/duplicate", to: "admin/surveys#duplicate", as: :admin_survey_duplicate
  post "/admin/notes(/:id/patch)", to: "admin/notes#patch", as: :admin_note_patch
  post "/admin/survey_groups/:id/patch", to: "admin/survey_groups#patch", as: :admin_survey_group_patch
  post "/admin/survey_questions/:id/patch", to: "admin/survey_questions#patch", as: :admin_survey_question_patch

  get "login/:token", to: "home#login", as: :login
  get "logout", to: "home#logout", as: :logout
  get "send_magic_link", to: "home#send_magic_link", as: :send_magic_link
  get "unsubscribe/:token", to: "home#unsubscribe", as: :unsubscribe
  get "user_search", to: "admin/users#search", as: :user_search
  
  # yes, these parameters need to be optional because they will be modified by js
  get  "survey/notes/:token", to: "survey_invites#notes", as: :survey_notes
  post "survey/patch/:token(/:id)", to: "survey_invites#patch", as: :survey_patch
  get  "survey/live/:token", to: "survey_invites#live_view", as: :survey_live_view
  get  "survey/results/:token", to: "survey_invites#show_results", as: :survey_show_results
  get  "survey(/:token)(/:group_position/:question_position)", to: "survey_invites#show", as: :survey

  namespace :admin do
    resources :users, only: [:index, :edit, :update]
    resources :roles, only: [:index, :edit, :update]
  end

  namespace :greeters do
    resources :users, only: [:index, :edit, :update]
  end

    resources :users, param: :token, only: [:index, :show]
    resources :surveys do
      resources :survey_invites, only: [:new, :create]
      resources :notes, only: [:index, :create, :destroy]
      resources :survey_groups, only: [:new, :create, :edit, :update, :destroy] do
        resources :survey_questions, only: [:new, :create, :edit, :update, :destroy]
      end
    end
  end

  resources :users, param: :token, only: [:show, :edit, :update]

  root to: "home#index"
end
