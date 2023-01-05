class HomeController < ApplicationController
  layout "home"

  def index
    return redirect_to admin_users_url if current_user_has_role(:greeter)
  end

  def login
    sign_in
    return redirect_to root_url unless current_user
    return redirect_to admin_users_url if current_user.has_role(:greeter)
    render :show
  end

  def logout
    current_user.update(session_token: nil)
    cookies.delete :session_token
    redirect_to root_url
  end

  def send_magic_link
    params.permit(:email)
    user = User.find_by_email params[:email].downcase
    if user
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
    redirect_to root_url
  end
end
