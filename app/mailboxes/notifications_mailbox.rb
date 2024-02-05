class NotificationsMailbox < ApplicationMailbox
  def process
    # write out email body for debugging
    file = File.new("tmp/last_email", "w")
    file.write(mail.body.decoded)
    file.close

    # get link to comment or post or article
    match = mail.body.decoded.match(/: (https:\/\/mightynetworks.com.+?)\?/)
    ModerationAssessment.create(url: match[1]) if match
  end
end
