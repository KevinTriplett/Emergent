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
    ApproveUserSpider.logger.info "SPIDER #{name} STARTING"
    request_to(:sign_in, url: "https://emergent-commons.mn.co/sign_in") unless response_has("body.communities-app")
    request_to(:approve_user, url: "https://emergent-commons.mn.co/settings/invite/requests")
    ApproveUserSpider.logger.info "#{name} COMPLETED SUCCESSFULLY"
  rescue => error
    ::Spider.set_result(name, "failure")
    ApproveUserSpider.logger.fatal "#{name} COMPLETED FAILURE: #{error.message}"
  end

  def approve_user(response, url:, data: {})
    data = Marshal.load ::Spider.get_message(name)
    first_name, last_name = data[:first_name], data[:last_name]
    ApproveUserSpider.logger.info "APPROVING #{first_name} #{last_name}"

    ############################################
    # wait until the modal dialog box is visible
    css = ".invite-list-container tr.invite-request-list-item"
    wait_until(css)

    ############################################
    # find approve button for this user
    first_name_td = "td.invite-list-item-first-name[title='#{first_name}']"
    last_name_td = "td.invite-list-item-last-name[title='#{last_name}']"
    css_row = "#{css}:has(#{first_name_td}):has(#{last_name_td})"
    css_approve = "#{css_row} a.invite-list-item-approve-button"
    ApproveUserSpider.logger.debug "LOOKING FOR #{css_approve}"
    browser.find(:css, css_approve).click if Rails.env.production? || Rails.env.staging?

    ############################################
    # update the member's new id
    sleep 4
    ApproveUserSpider.logger.debug "ATTEMPTING TO GET MEMBER ID"
    css_link = "#{css_row} .invite-list-item-first-name-text a"
    link = browser.find(:css, css_link)["href"]

    member_id = link.split("/").last
    ApproveUserSpider.logger.info "GOT MEMBER ID '#{member_id}'"
    ::Spider.set_result(name, member_id)
  end
end
