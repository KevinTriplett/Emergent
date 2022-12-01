require 'emerge_spider'

class ApproveUserSpider < EmergeSpider
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "approve_user_spider"
  @engine = :selenium_chrome
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
    attr_accessor :user_email
  end

  def wait_for_trigger
    ApproveUserSpider.user_email = nil
    ApproveUserSpider.logger.info "STARTING"
    request_to :sign_in, url: "https://emergent-commons.mn.co/sign_in"
    report_failure_unless_response_has("body.communities-app")
    ApproveUserSpider.logger.info "ENTERING LOOP"
    loop do
      if ApproveUserSpider.user_email
        ApproveUserSpider.logger.info "APPROVING USER WITH EMAIL #{ApproveUserSpider.user_email}"
        request_to :approve_user, url: "https://emergent-commons.mn.co/settings/invite/requests"
        ApproveUserSpider.user_email = nil
      else
        sleep 2
      end
    end
    ApproveUserSpider.logger.info "EXITING LOOP"
    ApproveUserSpider.logger.info "COMPLETED SUCCESSFULLY"
  end

  def approve_user(response, url:, data: {})
    ApproveUserSpider.logger.debug "ATTEMPTING TO FIND AND CLICK APPROVE FOR USER WITH EMAIL #{ApproveUserSpider.user_email}"
    css = ".invite-list-container tr.invite-request-list-item"
    wait_until(css)

    css += ":has(.invite-list-item-email-text[title='#{ApproveUserSpider.user_email}'])"
    css += " a.invite-list-item-approve-button"
    ApproveUserSpider.logger.debug "LOOKING FOR #{css}"
    browser.find(:css, css).click
  end
end
