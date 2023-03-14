class UserMailer < ApplicationMailer
  def send_magic_link
    @user = params
    @url = login_url(token: @user.token, protocol: "https")
    headers['List-Unsubscribe'] = "<#{unsubscribe_url(token: @user.token, protocol: "https")}>"
    mail(to: @user.email, subject: "Emergent Commons - your magic link")
  end

  def send_survey_invite_link
    @invite = params[:invite]
    message = params[:message].split("|")
    user = User.find message[0]
    subject = message[1]
    body = "#{message[2]}\n#{message[3]}\n#{message[4]}"
    headers['List-Unsubscribe'] = "<#{unsubscribe_url(token: @invite.token, protocol: "https")}>"
    mail(to: user.email, subject: subject, body: body, content_type: "text/plain")
  end

  def send_finished_survey_link
    @invite = params[:invite]
    message = params[:message].split("|")
    user = User.find message[0]
    subject = message[1]
    body = "#{message[2]}\n#{message[3]}\n#{message[4]}"
    headers['List-Unsubscribe'] = "<#{unsubscribe_url(token: @invite.token, protocol: "https")}>"
    mail(to: user.email, subject: subject, body: body, content_type: "text/plain")
  end

  def send_greeter_invite_email
    user = params[:user]
    subject = params[:subject]
    body = params[:body]
    mail(to: user.email, subject: subject, body: body, content_type: "text/plain")
  end
end