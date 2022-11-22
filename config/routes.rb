Rails.application.routes.draw do
  namespace :admin do
    resources :greeters, only: [:index, :show, :new, :create]
    resources :members, only: [:index]
  end

  root to: "members#index"
end
