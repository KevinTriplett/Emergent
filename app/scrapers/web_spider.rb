require 'kimurai'

class WebSpider < Kimurai::Base
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "spider"
  @engine = :selenium_chrome
  @start_urls = ["https://emergent-commons.mn.co/sign_in"]
  @config = {
    user_agent: USER_AGENT,
    disable_images: true,
    before_request: {
      # Change user agent before each request:
      change_user_agent: false,
      # Change proxy before each request:
      change_proxy: false,
      # Clear all cookies and set default cookies (if provided) before each request:
      clear_and_set_cookies: false,
      # Process delay before each request:
      delay: 2..4
    }
  }

  def parse(response, url:, data: {})
    sign_in
    report_failure_unless_response_has("body.communities-app")
    browser.save_screenshot
  end

  def sign_in
    unless response_has("body.auth-sign_in")
      puts "WAITING FOR body.auth-sign_in ..."
      sleep 1
    end
    puts "SIGNING IN"
    browser.fill_in "Email", with: "ec.test@kevintriplett.com"
    sleep 1
    browser.fill_in "Password", with: "Aggies@1984"
    browser.click_link "Sign In"
    sleep 5
    while response_has(".pace-running")
      puts "WAITING WHILE body.pace-running ..."
      sleep 5
    end
    sleep 5
    puts "SUCCESS!"
  end

  def report_failure_unless_response_has(css)
    return if response_has(css)
    puts "Expected to find #{css}"
    raise
  end

  def response_has(css)
    browser.current_response.css(css).length > 0
  end
end
