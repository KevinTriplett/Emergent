class UserMailer < ApplicationMailer
  def send_magic_link
    @user = params
    headers['List-Unsubscribe'] = "<#{unsubscribe_url(token: @user.token, protocol: "https")}>"
    @url = login_url(token: @user.token, protocol: "https")
    mail(to: @user.email, subject: "Emergent Commons - your magic link")
  end
end