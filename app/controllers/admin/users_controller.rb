module Admin
  class UsersController < ApplicationController
    layout "admin"
    before_action :signed_in_user

    def index
      date = Time.now - 1.month
      @users = User.order(request_timestamp: :desc).where('request_timestamp >= ? OR greeter_id = ?', date, current_user.id)
      @update_url = admin_users_url
      @token = form_authenticity_token
    end

    def show
      @user = User.find(params[:id])
      @status_options = @user.get_status_options
      @token = form_authenticity_token
    end

    def patch
      _ctx = run User::Operation::Patch, admin_name: current_user.name do |ctx|
        return render json: { 
          model: ctx[:model].reload,
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

    def search
      params.permit(:search_terms, user: {}) # TODO: why is an empty user hash being received?
      name = params[:search_terms].chomp.gsub('  ', ' ')
      name = "%#{name}%" # do this outside the LIKE statement
      like_name = "name LIKE '%#{name}%'"
      # puts "sql = #{User.where(like_name).order(last_name: :asc).to_sql}"
      users = User.where(like_name).order(last_name: :asc)
      user_ids_names = users.collect {|u| [u.id, u.name]}
      render json: { users: user_ids_names }
    end
  end
end