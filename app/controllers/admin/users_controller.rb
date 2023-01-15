module Admin
  class UsersController < ApplicationController
    layout "admin"
    before_action :signed_in_user

    def index
      @search_url = admin_search_users_url
      @user_url = admin_users_url
    end

    def search
      return render json: {
        users: User.where("name like ?", "%#{params[:search]}%")
      }
    end

    def edit
      _ctx = run User::Operation::Update::Present, admin_name: current_user.name do |ctx|
        return render json: { user: ctx[:model].reload }
      end
      return head(:bad_request)
    end

    def update_user
      _ctx = run User::Operation::Update, admin_name: current_user.name do |ctx|
        return render json: { user: ctx[:model].reload }
      end
      return head(:bad_request)
    end

    def approve_user
      _ctx = run User::Operation::Approve, admin: current_user do |ctx|
        flash[:notice] = "User approved -- thank you!"
        return render json: { url: admin_user_url(ctx[:model].id) }
      end
      return head(:bad_request)
    end

    private

    def init_vars
      
    end
  end
end