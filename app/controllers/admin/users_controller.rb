module Admin
  class UsersController < ApplicationController
    layout "greeter"
    before_action :signed_in_user

    # ------------------------------------------------------------------------

    def index
      date = Time.now - 3.months
      users = User
        .order(request_timestamp: :desc)
        .where('request_timestamp >= ? OR greeter_id = ?', date, current_user.id)
      @users = map_users_for_index_view(users)
      @update_url = admin_users_url
      @token = form_authenticity_token
    end

    # ------------------------------------------------------------------------

    def show
      @user = User.find_by_token(params[:token])
      @status_options = @user.get_status_options
      @token = form_authenticity_token
    end
    
    # ------------------------------------------------------------------------

    def wizard
      @user = User.find_by_token(params[:token])
      case params[:status]
      when "scheduling-zoom"
        @user.update status: "Scheduling Zoom"
        flash[:notice] = "User successfully transitioned to scheduling zoom"
        return redirect_to admin_user_wizard_url(token: @user.token)
      when "zoom-scheduled"
        @user.update status: "Zoom Scheduled"
        flash[:notice] = "User successfully transitioned to zoom scheduled"
        return redirect_to admin_user_wizard_url(token: @user.token)
      when "zoom-done"
        @user.update status: "Zoom Done (completed)"
        return redirect_to admin_user_wizard_url(token: @user.token)
      when "chat-done"
        @user.update status: "Chat Done (completed)"
        return redirect_to admin_user_wizard_url(token: @user.token)
      when "zoom-declined"
        @user.update status: "Zoom Declined (completed)"
        return redirect_to admin_user_wizard_url(token: @user.token)
      when "no-resposne"
        @user.update status: "No Response (completed)"
        return redirect_to admin_user_wizard_url(token: @user.token)
      end
      @token = form_authenticity_token
      @body_class = "user-wizard"
    end

    # ------------------------------------------------------------------------

    def patch
      _ctx = run User::Operation::Patch, admin_name: current_user.name do |ctx|
        return render json: { 
          model: ctx[:model].reload,
          status_options: ctx[:model].get_status_options
        }
      end
      return head(:bad_request)
    end

    # ------------------------------------------------------------------------

    def approve_user
      _ctx = run User::Operation::Approve, admin: current_user do |ctx|
        flash[:notice] = "User approved -- thank you!"
        return render json: { url: admin_user_wizard_url(token: ctx[:model].token) }
      end
      return head(:bad_request)
    end

    # ------------------------------------------------------------------------

    def search
      params.permit(:q, :source, user: {}) # TODO: why is an empty user hash being received?
      name = params[:q].chomp.gsub('  ', ' ').gsub(/[^a-zA-Z ]/, '')
      name = "%#{name}%" # do this outside the LIKE statement
      source = params[:source]
      
      like_clause = (Rails.env.staging? || Rails.env.staging?) ?
      "name ILIKE '#{name}'" :
      "UPPER(name) LIKE '#{name.upcase}'"

      users = User.where(like_clause).order(last_name: :asc)
      users = case source
      when "greeter"
        map_users_for_index_view(users)
      else
        users.collect {|u| [u.id, u.name]}
      end
      render json: { users: users }
    end

    # ------------------------------------------------------------------------

    def token_command
      # params.permit(:command)
      user = User.find_by_token(params[:token])
      case params[:command]
      when "generate"
        user.generate_tokens
        flash[:notice] = "Tokens generated"
      when "regenerate"
        user.regenerate_tokens
        flash[:notice] = "Tokens regenerated"
      when "revoke"
        user.revoke_tokens
        flash[:notice] = "Tokens revoked"
      when "toggle_lock"
        user.locked? ? user.unlock : user.lock
        flash[:notice] = "User account #{user.locked? ? nil : "un"}locked"
      else
        flash[:error] = "Unknown action requested #{params[:command]}"
      end
      redirect_to admin_user_url(token: user.token)
    end

    # ------------------------------------------------------------------------

    private

    def map_users_for_index_view(users)
      users.map do |u|
        css_class = []
        css_class.push("pending") unless u.joined?
        css_class.push("declined") if "Request Declined" == u.status
        css_class.push("scheduling") if "Scheduling Zoom" == u.status
        css_class.push("scheduled") if "Zoom Scheduled" == u.status
        css_class.push("complete") if u.status.index("(completed)")
        done = u.status.match /completed/
        {
          "name": u.name,
          "greeter": u.greeter ? u.greeter.name : nil,
          "greeter_id": u.greeter_id,
          "status": u.status,
          "when": u.when_timestamp ? u.when_timestamp.picker_datetime : nil,
          "shadow": u.shadow_greeter ? u.shadow_greeter.name : nil,
          "shadow_id": u.shadow_greeter_id,
          "notes": u.notes_abbreviated,
          "truncated": u.notes ? u.notes.truncate(500, separator: ' ') : nil,
          "request": u.request_timestamp ? u.request_timestamp.picker_date : nil,
          "url": done ? admin_user_url(token: u.token) : admin_user_wizard_url(token: u.token),
          "token": u.token,
          "id": u.id,
          "css_class": css_class.join(" ")
        }
      end
    end
  end
end