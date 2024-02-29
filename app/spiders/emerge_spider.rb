require 'kimurai'
require 'selenium-webdriver'

class EmergeSpider < Kimurai::Base
  class EmailCloaked < StandardError
  end
  class CssNotFound < StandardError
  end
  
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @@engine = Rails.env.production? ? :selenium_chrome : :selenium_firefox
  @@urls = ["https://emergent-commons.mn.co/sign_in"]
  @@config = {
    user_agent: USER_AGENT,
    disable_images: true,
    window_size: [1690, 600],
    user_data_dir: Rails.root.join('shared', 'tmp', 'chrome_profile').to_s,
    retry_request_errors: [
      EOFError,
      Net::ReadTimeout,
      Selenium::WebDriver::Error::InvalidSelectorError,
      EmailCloaked,
      CssNotFound
    ],
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

  def name
    logger.progname
  end

  def self.create_spider(name)
    ::Spider.create(name: name) unless ::Spider.find_by_name(name)
  end

  def self.open_spider
    ::Spider.clear_result(name)
    logger.info "using #{@@engine} browser"
    logger.info "> STARTING"
  end

  def self.close_spider
    run_info[:status] == :completed ?
      ::Spider.set_success(name) :
      ::Spider.set_failure(name)
    logger.info "> COMPLETED WITH RESULT = '#{::Spider.get_result(name)}'"
  end

  def get_message
    ::Spider.get_message(name)
  end
  def get_and_clear_message
    ::Spider.get_message_and_clear(name)
  end

  def sign_in_and_send_request_to(role, method, url)
    logger.debug "> REQUEST TO #{url}"
    sign_in(role)
    request_to(method, url: url)
  end

  def set_result(result)
    ::Spider.set_result(name, result)
  end
  def set_message(msg)
    ::Spider.set_message(name, msg)
  end

  def sign_in(role)
    email, password = case role
    when :greeter, :moderator, :surveyor
      [Rails.configuration.mn_greeter_username, Rails.configuration.mn_greeter_password]
    when :moderation
      [Rails.configuration.mn_moderation_username, Rails.configuration.mn_moderation_password]
    # TODO: restore when/if surveyor account is created
    # when :surveyor
    #   [Rails.configuration.mn_surveyor_username, Rails.configuration.mn_surveyor_password]
    end

    logger.info "> SIGN IN"
    wait_until("body.auth-sign_in")
    browser.fill_in "Email", with: email
    browser.fill_in "Password", with: password
    browser.click_link "Sign In"

    wait_while(".pace-running")
    wait_until("body.communities-app")
    logger.info "> SIGN IN SUCCESSFUL"
  end

  def response_has(css, text=nil)
    browser.current_response.css(css).length > 0 && (!text || browser.current_response.css(css).text == text)
  end

  def wait_while(css, text=nil)
    for i in 0..10
      return true unless response_has(css, text)
      logger.debug "> WAITING WHILE #{css} ..."
      sleep 1
    end
    raise_error_if_response_has(css)
  end

  def wait_until(css, text=nil)
    for i in 0..10
      return true if response_has(css, text)
      logger.debug "> WAITING UNTIL #{css} ..."
      sleep 1
    end
    raise_error_unless_response_has(css)
  end

  def raise_error_unless_response_has(css)
    return true if response_has(css)
    browser.save_screenshot
    raise CssNotFound, "#{name}: > ERROR: could not find css \"#{css}\""
  end

  def raise_error_if_response_has(css)
    return true unless response_has(css)
    browser.save_screenshot
    raise CssNotFound, "#{name}: > ERROR: could not find css \"#{css}\""
  end
end
