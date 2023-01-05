require 'emerge_spider'

class ApproveUserSpider < EmergeSpider
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "approve_user_spider"
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
    NewUserSpider.logger.info "SPIDER #{name} STARTING"
    request_to(:sign_in, url: "https://emergent-commons.mn.co/sign_in") unless response_has("body.communities-app")

    request_to :approve_user, url: "https://emergent-commons.mn.co/settings/invite/requests"

    ApproveUserSpider.logger.info "#{name} COMPLETED SUCCESSFULLY"
  rescue => error
    ::Spider.set_result(name, "failure")
    ApproveUserSpider.logger.fatal "#{name} COMPLETED FAILURE: #{error.message}"
  end

  def approve_user(response, url:, data: {})
    email = ::Spider.get_message(name)
    ApproveUserSpider.logger.info "APPROVING USER WITH EMAIL #{email}"
    ApproveUserSpider.logger.debug "ATTEMPTING TO FIND AND CLICK APPROVE BUTTON FOR USER WITH EMAIL #{email}"
    css = ".invite-list-container tr.invite-request-list-item"
    wait_until(css)

    email_div = ".invite-list-item-email-text[title='#{email}']"
    css += ":has(#{email_div})"
    css += " a.invite-list-item-approve-button"
    ApproveUserSpider.logger.debug "LOOKING FOR #{css}"
    browser.find(:css, css).click # if Rails.env.production? || Rails.env.staging?

    # update the member's new id
    ApproveUserSpider.logger.debug "ATTEMPTING TO GET MEMBER ID"
    css = "#{email_div} a"
    wait_until(css)
    link = browser.find(:css, css)["href"]

    member_id = link.split("/").last
    ApproveUserSpider.logger.debug "GOT MEMBER ID '#{member_id}'"
    ::Spider.set_result(name, member_id)
  end
end
