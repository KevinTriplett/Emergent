class NotificationsMailbox < ApplicationMailbox
  def process
    # write out email body for debugging
    file = File.new("tmp/last_email", "w")
    file.write(mail.body.decoded)
    file.close

    # get link to comment or post
    match = mail.body.decoded.match(/See Comment: (https:\/\/mightynetworks.com.+?)\?/)
    url = match[1] if match
    match = mail.body.decoded.match(/See Post: (https:\/\/mightynetworks.com.+?)\?/)
    url = match[1] if match

    # ignore if no url
    ModerationAssessment.create(url: url) if url
  end
end
