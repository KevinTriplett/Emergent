class NotificationsMailbox < ApplicationMailbox
  def process
    # get link to comment or post or article
    match = mail.body.decoded.match(/(\w+?): (https:\/\/mightynetworks.com.+?)\?/)
    what = match[1] if match
    url = match[2] if match
    ModerationAssessment.create(url: url, what: what, state: 0) if url

    # write out email body for debugging
    file = File.new("tmp/last_email", "w")
    file.write("What: #{what} || URL: #{url}\n---------------------------------\n")
    file.write(mail.body.decoded)
    file.close
  end
end
