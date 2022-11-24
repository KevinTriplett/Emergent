Rails.application.routes.draw do
  namespace :admin do
    resources :users, only: [:index, :update]
  end

  root to: "home#index"
end
