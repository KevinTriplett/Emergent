require 'emerge_spider'

class MagicLinkSpider < EmergeSpider
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "magic_link_spider"
  @engine = Rails.env.development? ? :selenium_firefox : :selenium_chrome
  @start_urls = ["https://emergent-commons.mn.co/sign_in"]
  @config = {
    user_agent: USER_AGENT,
    disable_images: true,
    window_size: [1366, 768],
    user_data_dir: Rails.root.join('shared', 'tmp', 'chrome_profile').to_s,
    before_request: {
      # Change user agent before each request:
      change_user_agent: false,
      # Change proxy before each request:
      change_proxy: false,
      # Clear all cookies and set default cookies (if provided) before each request:
      clear_and_set_cookies: false,
      # Process delay before each request:
      delay: 1..2
    }
  }
  ::Spider.create(name: @name) unless ::Spider.find_by_name(@name)

  def parse(response, url:, data: {})
    logger.info "STARTING"
    sign_in

    @@url, user_id = get_message.split("|")

    user = User.find user_id
    send_request_to(:send_link, user.chat_url)
  end

  def send_link(response, url:, data: {})
    logger.info "SPIDER OPENING CHAT CHANNEL"
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
    logger.info "SPIDER SENT LINK VIA CHAT CHANNEL"
  end
end
