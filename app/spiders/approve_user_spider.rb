require 'emerge_spider'

class ApproveUserSpider < EmergeSpider
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "approve_user_spider"
  @engine = Rails.env.development? ? :selenium_firefox : :selenium_chrome
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
    request_to(:approve_user, url: "https://emergent-commons.mn.co/settings/invite/requests")
    EmergeSpider.logger.info "#{name} COMPLETED SUCCESSFULLY"
  rescue => error
    set_result(Rails.env.development? ? "success" : "failure")
    EmergeSpider.logger.fatal "#{name} #{error.class}: #{error.message}"
  end

  def approve_user(response, url:, data: {})
    first_name, last_name = get_message.split('|')
    EmergeSpider.logger.info "APPROVING #{first_name} #{last_name}"

    ############################################
    # wait until the modal dialog box is visible
    css = ".invite-list-container tr.invite-request-list-item"
    wait_until(css)

    ############################################
    # see if user has already joined (database out of sync with MN database)
    first_name_td = "td.invite-list-item-first-name[title='#{first_name}']"
    last_name_td = "td.invite-list-item-last-name[title='#{last_name}']"
    css_row = "#{css}:has(#{first_name_td}):has(#{last_name_td})"
    css_status = "#{css_row} .invite-list-item-status-text"
    return get_member_id(css_row) if response_has(css_status, "Joined!")
    # NB: do not approve except in production!
    return set_result("testing") unless Rails.env.production?

    ############################################
    # find approve button for this user
    css_approve = "#{css_row} a.invite-list-item-approve-button"
    EmergeSpider.logger.debug "LOOKING FOR #{css_approve}"
    begin
      browser.find(:css, css_approve).click
      wait_until(css_status, "Joined!")
    rescue Selenium::WebDriver::Error::ElementNotInteractableError
      EmergeSpider.logger.fatal "Approve button not interactable on MN platform"
    end

    ############################################
    # update the member's new id
    get_member_id(css_row)
  end

  def get_member_id(css)
    EmergeSpider.logger.debug "ATTEMPTING TO GET MEMBER ID"
    css_link = "#{css} .invite-list-item-first-name-text a"
    link = browser.find(:css, css_link)["href"]

    member_id = link.split("/").last
    EmergeSpider.logger.info "GOT MEMBER ID '#{member_id}'"
    set_result(member_id)
  end
end
