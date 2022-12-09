module Admin
  class UsersController < ApplicationController
    layout "admin"

    def index
      date = ("2022-11-18").to_date
      @users = User.order(request_timestamp: :desc).where('request_timestamp >= ?', date)
      @update_url = admin_users_url
      @token = form_authenticity_token
      @options = [
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
      until result = Spider.get_result
        sleep 1
      end
      if result == "success"
        user.update(status: "Joined!")
        flash[:notice] = "#{user.name} was approved"
      else
        flash[:error] = "#{user.name} could not be approved - talk to Kevin"
      end
      redirect_to admin_users_url
    end
  end
end