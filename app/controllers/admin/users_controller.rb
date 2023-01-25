module Admin
  class UsersController < ApplicationController
    layout "admin"
    before_action :signed_in_user

    def index
      @search_url = admin_search_users_url
      @users = [current_user]
    end

    def search
      params.permit(:search_terms)
      return render json: {
        users: User.where("name like ?", "%#{params[:search_terms]}%")
      }
    end

    def edit
      _ctx = run User::Operation::Update::Present, admin_name: current_user.name do |ctx|
        return render json: { user: ctx[:model].reload }
      end
      return head(:bad_request)
    end

    def show
      @user = User.find(params[:id])
      @status_options = @user.get_status_options
      @token = form_authenticity_token
    end

    def update_user
      _ctx = run User::Operation::Update, admin_name: current_user.name do |ctx|
        return render json: { 
          user: ctx[:model].reload,
          status_options: ctx[:model].get_status_options
        }
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