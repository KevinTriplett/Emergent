module Admin
  class RolesController < ApplicationController
    layout "admin"
    before_action :signed_in_user

    def index
      @search_url = admin_search_users_url
      @token = form_authenticity_token
    end

    def show
      @user = User.find(params[:id])
      @token = form_authenticity_token
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