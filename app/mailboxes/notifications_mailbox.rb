require 'nokogiri'

class NotificationsMailbox < ApplicationMailbox
  def process
    doc = Nokogiri::HTML(mail.body.decoded)
    # get link to comment or post
    url = doc.css('table.button-action-container a')[0].attribute_nodes[1].value.split('?')[0]
    # ignore if not a comment or post
    ModerationAssessment.create(url: url) if /post/.match(url)
  end
end
