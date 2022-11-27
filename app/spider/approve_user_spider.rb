require 'emerge_spider'

class ApproveUserSpider < EmergeSpider
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "new_user_spider"
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
      delay: 2..4
    }
  }

  # class level instance variable, not a class variable
  # ref https://stackoverflow.com/questions/21122691/attr-accessor-on-class-variables
  class << self
    attr_accessor :user_profile_url
  end

  def parse(response, url:, data: {})
    puts "APPROVING USER WITH PROFILE URL #{ApproveUserSpider.user_profile_url}"
    sign_in
    report_failure_unless_response_has("body.communities-app")
    # browser.save_screenshot
    request_to :approve_user, url: "https://emergent-commons.mn.co/settings/invite/requests"
    # browser.save_screenshot
    puts "COMPLETED SUCCESSFULLY"
  end

  # TODO: fill in missing information for users after they join
  def approve_user(response, url:, data: {})
    puts "LOOKING FOR USER WITH PROFILE URL #{ApproveUserSpider.user_profile_url}"
    row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)

    browser.current_response.css(row_css).each_with_index do |row, idx|
      next unless row.css("a.navigate[href='#{ApproveUserSpider.user_profile_url}']").count == 0
      puts "FOUND USER, ATTEMPTING TO APPROVE"
      css = "a.invite-list-item-approve-button"
      row.find(css).first.click
      sleep 1
      # double check if possible that the approve button is no longer visible
      break
    end
  end
end
