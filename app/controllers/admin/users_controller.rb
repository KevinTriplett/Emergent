module Admin
  class UsersController < ApplicationController
    layout "admin"

    def index
      date = ("2022-11-18").to_date
      @users = User.order(request_timestamp: :desc).where('request_timestamp >= ?', date)
      @update_url = admin_users_url
      @token = form_authenticity_token
      @options = get_status_options
    end

    def show
      @user = User.find(params[:id])
      @update_url = admin_users_url
      @token = form_authenticity_token
      @options = get_status_options
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
      Spider.set_message("approve_user_spider", user.email)
      ApproveUserSpider.crawl!
      until result = Spider.get_result("approve_user_spider")
        sleep 1
      end
      user.update(status: "Joined!") if result == "success"
      render json: {result: result}
    end

    private

    def get_status_options
      return [
        "Pending",
        "Joined!",
        "1st Email Sent",
        "2nd Email Sent",
        "Emailing",
        "No Response",
        "Rescheduling",
        "Follow Up",
        "Will Call",
        "Greet Scheduled",
        "Declined",
        "Welcomed",
        "Posted Intro",
        "Completed"
      ]
    end
  end
end