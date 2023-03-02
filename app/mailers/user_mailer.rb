class UserMailer < ApplicationMailer
  def send_magic_link
    @user = params
    @url = login_url(token: @user.token, protocol: "https")
    headers['List-Unsubscribe'] = "<#{unsubscribe_url(token: @user.token, protocol: "https")}>"
    mail(to: @user.email, subject: "Emergent Commons - your magic link")
  end

  def send_survey_invite_link
    @invite = params[:invite]
    @message = Marshal.load(params[:message])
    headers['List-Unsubscribe'] = "<#{unsubscribe_url(token: @invite.token, protocol: "https")}>"
    mail(to: params[:email], subject: @message[:subject])
  end

  def send_finished_survey_link
    @invite = params[:invite]
    @message = Marshal.load(params[:message])
    headers['List-Unsubscribe'] = "<#{unsubscribe_url(token: @invite.token, protocol: "https")}>"
    mail(to: params[:email], subject: @message[:subject])
  end
end