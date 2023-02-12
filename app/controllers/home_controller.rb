class HomeController < ApplicationController
  layout "home"

  def index
    return redirect_to admin_users_url if current_user_has_role(:greeter)
  end

  def login
    sign_in
    return redirect_to root_url unless current_user
    return redirect_to admin_users_url if current_user.has_role(:greeter)
    redirect_to root_url
  end

  def logout
    sign_out
    flash[:notice] = "You have logged out"
    redirect_to root_url
  end

  def send_magic_link
    params.permit(:email) # initially email, now email or name
    email = params[:email].blank? ? "zzzzzzzzzzz" : params[:email]
    user = User.find_by_email(email.downcase) || User.find_by_name(email)
    user ||= User.where("name ILIKE #{email}")
    if user && !Rails.env.production?
      sign_in(user)
    elsif user
      user.generate_tokens
      url = login_url(token: user.token, protocol: "https")
      Spider.set_message("magic_link_spider", "#{url}|#{user.id}")
      MagicLinkSpider.crawl!
      until result = Spider.get_result("magic_link_spider")
        sleep 1
      end
      if result == "success"
        flash[:notice] = "Magic link sent, check your Emergent Commons chat channel"
      else
        flash[:error] = "Failed to send your magic link"
      end
    else
      flash[:error] = "Please enter your Mighty Networks name or email address"
    end
    redirect_to root_url
  end

  def unsubscribe
    #TODO: do something
    flash[:notice] = "You have been successfully unsubscribed"
    redirect_to root_url
  end
end
