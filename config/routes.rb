Rails.application.routes.draw do
  
  get  "admin/users/:token/token/:command", to: "admin/users#token_command", as: :admin_user_token
  post "admin/users/:token/patch", to: "admin/users#patch", as: :admin_user_patch
  post "admin/users/:token/approve", to: "admin/users#approve_user", as: :admin_approve_user
  get  "admin/users/:token/wizard", to: "admin/users#wizard", as: :admin_user_wizard
  post "admin/users/:token/email", to: "admin/users#send_email", as: :admin_user_send_email
  
  get  "admin/surveys/:id/test", to: "admin/surveys#test", as: :admin_survey_test
  get  "admin/surveys/:id/report", to: "admin/surveys#report", as: :admin_survey_report
  get  "admin/surveys/:id/notes/new", to: "admin/surveys#new_note", as: :new_admin_survey_note
  get  "admin/surveys/:id/duplicate", to: "admin/surveys#duplicate", as: :admin_survey_duplicate
  post "admin/notes(/:id/patch)", to: "admin/notes#patch", as: :admin_note_patch
  post "admin/survey_groups/:id/patch", to: "admin/survey_groups#patch", as: :admin_survey_group_patch
  post "admin/survey_questions/:id/patch", to: "admin/survey_questions#patch", as: :admin_survey_question_patch

  get "login/:token", to: "home#login", as: :login
  get "logout", to: "home#logout", as: :logout
  get "send_magic_link", to: "home#send_magic_link", as: :send_magic_link
  get "unsubscribe/:token", to: "home#unsubscribe", as: :unsubscribe
  get "user_search", to: "admin/users#search", as: :user_search
  
  # yes, some of these params are optional because js will add the params
  get  "survey/live/:token", to: "survey_invites#live_view", as: :survey_live_view
  get  "survey/results/:token", to: "survey_invites#show_results", as: :survey_show_results
  post "survey/patch/:token(/:id)", to: "survey_invites#patch", as: :survey_patch
  get  "survey(/:token)(/:survey_question_id)", to: "survey_invites#show", as: :survey
  post "admin/survey_invites/:id/patch", to: "admin/survey_invites#patch", as: :admin_survey_invite_patch

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
