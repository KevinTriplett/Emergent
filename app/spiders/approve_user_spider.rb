require 'emerge_spider'

class ApproveUserSpider < EmergeSpider
  class EmailCloaked < StandardError
  end

  @name = "approve_user_spider"
  @engine = @@engine
  @start_urls = @@urls
  @config = @@config
  @config.retry_request_errors.push(EmailCloaked)
  create_spider(@name)

  def parse(response, url:, data: {})
    sign_in_and_send_request_to(:approve_user, "https://emergent-commons.mn.co/settings/invite/requests")
  end

  def approve_user(response, url:, data: {})
    first_name, last_name = get_and_clear_message.split('|')
    logger.info "> APPROVING #{first_name} #{last_name}"

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
    
    ############################################
    # NB: do not approve except in production!
    return set_result("1") unless Rails.env.production?

    ############################################
    # find approve button for this user
    css_approve = "#{css_row} a.invite-list-item-approve-button"
    logger.debug "> LOOKING FOR #{css_approve}"
    begin
      browser.find(:css, css_approve).click
      wait_until(css_status, "Joined!")
    rescue Selenium::WebDriver::Error::ElementNotInteractableError
      logger.fatal "> Approve button not interactable on MN platform"
    end

    ############################################
    # update the member's new id
    get_member_id(css_row)
  end

  def get_member_id(css)
    logger.debug "> ATTEMPTING TO GET MEMBER ID"
    css_link = "#{css} .invite-list-item-first-name-text a"
    link = browser.find(:css, css_link)["href"]

    member_id = link.split("/").last
    logger.info "> GOT MEMBER ID '#{member_id}'"
    set_result(member_id)
  end
end
