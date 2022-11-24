Rails.application.routes.draw do
  post "/admin/users(/:id)/update_user", to: "admin/users#update_user", as: :admin_update_user

  namespace :admin do
    resources :users, only: [:index, :update]
  end

  root to: "home#index"
end
