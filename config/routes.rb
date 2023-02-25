Rails.application.routes.draw do
  
  get  "/admin/users/:token/token/:command", to: "admin/users#token_command", as: :admin_user_token
  post "/admin/users/:token/patch", to: "admin/users#patch", as: :admin_user_patch
  post "/admin/users/:token/approve", to: "admin/users#approve_user", as: :admin_approve_user
  
  get  "/admin/surveys/:id/test", to: "admin/surveys#test", as: :admin_survey_test
  get  "/admin/surveys/:id/notes/new", to: "admin/surveys#new_note", as: :new_admin_survey_note
  post "/admin/notes(/:id/patch)", to: "admin/notes#patch", as: :admin_note_patch
  post "/admin/survey_groups/:id/patch", to: "admin/survey_groups#patch", as: :admin_survey_group_patch
  post "/admin/survey_questions/:id/patch", to: "admin/survey_questions#patch", as: :admin_survey_question_patch

  get "login/:token", to: "home#login", as: :login
  get "logout", to: "home#logout", as: :logout
  get "send_magic_link", to: "home#send_magic_link", as: :send_magic_link
  get "unsubscribe/:token", to: "home#unsubscribe", as: :unsubscribe
  get "user_search", to: "admin/users#search", as: :user_search
  
  # yes, these parameters need to be optional because they will be added by js in the view
  get  "survey(/:token)(/:group_position/:question_position)", to: "survey_invites#show", as: :survey
  post "survey/:token/patch(/:group_position/:question_position)", to: "survey_invites#patch", as: :survey_answer_patch

  namespace :admin do
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
