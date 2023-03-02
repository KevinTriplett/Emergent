require 'emerge_spider'

class PrivateMessageSpider < EmergeSpider
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "private_message_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://emergent-commons.mn.co/sign_in"]
  @config = {
    user_agent: USER_AGENT,
    disable_images: true,
    window_size: [1366, 768],
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
    EmergeSpider.logger.info "SPIDER #{name} STARTING"
    request_to(:sign_in, url: "https://emergent-commons.mn.co/sign_in") unless response_has("body.communities-app")

    @@message = Marshal.load(get_message)
    @@user = User.find @@message[:user_id]
    EmergeSpider.logger.info "SENDING MESSAGE TO #{@@user.name} FOR #{@@message[:subject]}"
    request_to(:send_message, url: @@user.chat_url)

    EmergeSpider.logger.info "#{name} COMPLETED SUCCESSFULLY"
    set_result("success")
  rescue => error
    set_result("failure")
    EmergeSpider.logger.fatal "#{name} #{error.class}: #{error.message}"
  end

  def send_message(response, url:, data: {})
    wait_until(".universal-input-form-body-container .fr-element.fr-view")
    EmergeSpider.logger.debug "#{name} ATTEMPTING TO CLICK CHAT CHANNEL"
    browser.find(:css, ".universal-input-form-body-container .fr-element.fr-view").click
    browser.send_keys(@@message[:subject])
    browser.send_keys [:enter]
    sleep 1
    browser.send_keys(@@message[:body])
    browser.send_keys [:enter]
    sleep 1
    @@message[:lines].each do |line|
      browser.send_keys(line)
      browser.send_keys [:enter]
      sleep 1
    end
    browser.send_keys(@@message[:url])
    browser.send_keys [:enter]
  end
end
