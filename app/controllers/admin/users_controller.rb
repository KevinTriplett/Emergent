module Admin
  class UsersController < ApplicationController
    layout "admin"

    unless Rails.env.test?
      http_basic_authenticate_with name: Rails.configuration.admin_name, password: Rails.configuration.admin_password
    end
  
    def index
      date = ("2022-11-18").to_date
      @users = User.order(request_timestamp: :desc).where('request_timestamp >= ?', date)
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

    def approve_user
      user = User.find(params[:id])
      ApproveUserSpider.user_email = user.email
      ApproveUserSpider.crawl!
      user.update!(status: "Joined!")
      redirect_to admin_users_url
    end
  end
end