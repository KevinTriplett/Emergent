class HomeController < ApplicationController
  layout "home"

  def index
    return redirect_to admin_users_url if current_user_has_role(:greeter)
  end

  def login
    sign_in
    return redirect_to root_url unless current_user
    return redirect_to admin_users_url if current_user.has_role(:greeter)
    redirect_back
  end

  def logout
    sign_out
    flash[:notice] = "You have logged out"
    redirect_to root_url
  end

  def send_magic_link
    params.permit(:email)
    _ctx = run User::Operation::MagicLink, email_or_name: params[:email] do |ctx|
      user = ctx[:user]
      if user && (Rails.env.staging? || Rails.env.development?)
        sign_in(user)
        return redirect_back(fallback_location: root_url)
      else
        user.generate_tokens
        UserMailer.with(user).send_magic_link.deliver_now
        if Rails.env.production?
          url = login_url(token: user.token, protocol: "https")
          Spider.append_message("magic_link_spider", "#{url}|#{user.id}")
        end
        flash[:notice] = "Magic link sent, check your email SPAM folder and your Emergent Commons chat channel"
      end
      return redirect_to root_url
    end
  
    flash[:error] = _ctx[:flash] || "Unable to find '#{params[:email]}' -- please try again"
    redirect_to root_url
  end

  def unsubscribe
    #TODO: do something
    flash[:notice] = "You have been successfully unsubscribed"
    redirect_to root_url
  end
end
