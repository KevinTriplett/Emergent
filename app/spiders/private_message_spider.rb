require 'emerge_spider'

class PrivateMessageSpider < EmergeSpider
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "private_message_spider"
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
    @@lines = get_and_clear_message.split("|")
    @@user = User.find @@lines.shift # first element in array is user_id
    sign_in_and_send_request_to(:send_message, @@user.chat_url) ?
      ::Spider.set_success(name) :
      ::Spider.set_failure(name)
    logger.info "COMPLETED WITH #{::Spider.success?(name) ? "SUCCESS" : "FAILURE"}"
  end

  def send_message(response, url:, data: {})
    logger.info "SENDING MESSAGE TO #{@@user.name} FOR #{@@lines.first}"
    wait_until(".universal-input.chat-prompt .fr-element.fr-view")
    logger.debug "ATTEMPTING TO CLICK CHAT CHANNEL"
    browser.find(:css, ".universal-input.chat-prompt .fr-element.fr-view").click
    logger.debug "ATTEMPTING TO SEND #{@@lines}"

    @@lines.each do |line|
      next if line.blank?
      browser.send_keys(line)
      browser.send_keys [:enter]
      browser.send_keys [:enter]
      sleep 2
    end
  end
end
