class HomeController < ApplicationController
  layout "home"

  def index
    # TODO: user dashboard
    return redirect_to admin_users_url if current_user && current_user.has_role?(:greeter)
    return redirect_to user_url(token: current_user.token) if current_user
  end

  def login
    sign_in
    return redirect_to root_url unless current_user
    return redirect_to admin_users_url if current_user.has_role?(:greeter)
    return redirect_to user_url(token: current_user.token) if current_user
    redirect_to root_url
  end

  def logout
    sign_out
    flash[:notice] = "You have logged out"
    redirect_to root_url
  end

  def send_magic_link
    params.permit(:email)
    user = User.find_by_email params[:email].downcase
    if user && Rails.env.staging?
      sign_in(user)
    elsif user
      user.ensure_token
      UserMailer.with(user).send_magic_link.deliver_now
      flash[:notice] = "Magic link sent, check your SPAM folder"
    else
      flash[:error] = "Email not found - use your Mighty Networks email address"
    end
    redirect_to root_url
  end

  def unsubscribe
    #TODO: do something
    flash[:notice] = "You have been successfully unsubscribed"
    redirect_to root_url
  end
end
