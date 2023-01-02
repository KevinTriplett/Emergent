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
        user = {user: ctx[:model]}
        return render json: user
      end
      return head(:bad_request)
    end

    def approve_user
      # TODO: move this into an operation
      user = User.find(params[:id])
      Spider.set_message("approve_user_spider", spider_data(user, "approve"))
      ApproveUserSpider.crawl!
      until result = Spider.get_result("approve_user_spider")
        sleep 1
      end
      user.reload
      render json: {
        result: result,
        profile_url: user.profile_url,
        chat_url: user.chat_url,
        status: user.status
      }
    end

    def reject_user
      # TODO: for future implementation
      return render json: {result: "failure"}

      # TODO: move this into an operation
      user = User.find(params[:id])
      Spider.set_message("approve_user_spider", spider_data(user, "reject"))
      ApproveUserSpider.crawl!
      until result = Spider.get_result("approve_user_spider")
        sleep 1
      end
      user.update(status: "Joined!") if result == "success"
      render json: {result: result}
    end

    private

    def spider_data(user, command)
      data = {
        action: "approve",
        email: user.email,
        admin_name: current_user.name
      }
      Marshal.dump data
    end
  end
end