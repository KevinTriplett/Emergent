module Admin
  class UsersController < ApplicationController
    layout "admin"

    unless Rails.env.test?
      http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
    end
  
    def index
      @users = User.order(joined_timestamp: :desc).all
      @update_url = admin_users_url
      @token = form_authenticity_token
    end

    def update_user
      _ctx = run User::Operation::Update do |ctx|
        user = {user: ctx[:model]}
        return render json: user
      end
      return head(:bad_request)
    end
  end
end