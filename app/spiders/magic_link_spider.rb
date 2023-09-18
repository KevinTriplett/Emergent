require 'emerge_spider'

class MagicLinkSpider < EmergeSpider
  @name = "magic_link_spider"
  @engine = @@engine
  @start_urls = @@urls
  @config = @@config
  create_spider(@name)

  def parse(response, url:, data: {})
    get_and_clear_message.split(",").each do |message|
      @@url, user_id = message.split("|")
      user = User.find user_id
      sign_in_and_send_request_to(:send_link, user.chat_url)
    end
  end

  def send_link(response, url:, data: {})
    logger.debug "> SPIDER OPENING CHAT CHANNEL"
    wait_until(".universal-input-form-body-container .fr-element.fr-view")
    browser.find(:css, ".universal-input-form-body-container .fr-element.fr-view").click
    browser.send_keys("Someone requested your Volunteer App magic link -- here it is:")
    browser.send_keys [:enter]
    sleep 1
    browser.send_keys(@@url)
    browser.send_keys [:enter]
    sleep 1
    browser.send_keys("If you did not request this link, alert a Moderation Team First Responder")
    browser.send_keys [:enter]
    logger.debug "> SPIDER SENT LINK VIA CHAT CHANNEL"
  end
end
