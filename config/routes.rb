Rails.application.routes.draw do
  namespace :admin do
    resources :greeters, only: [:index]
    resources :members, only: [:index, :new, :create, :edit, :update, :delete]
  end

  resource :greeter, param: :token, only: [:show] do
    resources :members, only: [:index, :update]
  end

  root to: "members#default"
end
