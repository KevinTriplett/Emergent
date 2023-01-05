module Admin
  class UsersController < ApplicationController
    layout "admin"
    before_action :signed_in_user

    def index
      date = ("2022-11-18").to_date
      @users = User.order(request_timestamp: :desc).where('request_timestamp >= ?', date)
      @update_url = admin_users_url
      @token = form_authenticity_token
      @options = User.get_status_options
    end

    def show
      @user = User.find(params[:id])
      @update_url = admin_users_url
      @token = form_authenticity_token
      @options = User.get_status_options
    end

    def update_user
      _ctx = run User::Operation::Update, admin_name: current_user.name do |ctx|
        return render json: {user: ctx[:model].reload}
      end
      return head(:bad_request)
    end

    def approve_user
      _ctx = run User::Operation::Approve, admin: current_user do |ctx|
        return render json: { url: admin_user_url(ctx[:model].id) }
      end
      return head(:bad_request)
    end
  end
end