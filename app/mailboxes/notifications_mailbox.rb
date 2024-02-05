class NotificationsMailbox < ApplicationMailbox
  def process
    # write out email body for debugging
    file = File.new("tmp/last_email", "w")
    file.write(mail.body.decoded)
    file.close

    # get link to comment or post or article
    match = mail.body.decoded.match(/Go to (\w+?): (https:\/\/mightynetworks.com.+?)\?/)
    type = match[1] if match
    url = match[2] if match
    ModerationAssessment.create(url: url, what: type) if url
  end
end
