module Admin
  class UsersController < ApplicationController
    layout "admin"

    unless Rails.env.test?
      http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
    end
  
    def index
      @users = User.order(joined_timestamp: :desc).all
    end

    def update
      _ctx = run User::Operation::Update do |ctx|
        flash[:notice] = "#{ctx[:model].name} was updated"
        return redirect_to admin_users_url
      end
    
      @form = _ctx["contract.default"] # FIXME: redundant to #create!
      render :edit, status: :unprocessable_entity
    end
  end
end