class UserMailer < ApplicationMailer
  def send_magic_link
    @user = params
    @url = login_url(token: @user.token, protocol: "https")
    headers['List-Unsubscribe'] = "<#{unsubscribe_url(token: @user.token, protocol: "https")}>"
    mail(to: @user.email, subject: "Emergent Commons - your magic link")
  end
end