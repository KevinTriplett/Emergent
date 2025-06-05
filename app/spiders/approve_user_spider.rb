require 'emerge_spider'

class ApproveUserSpider < EmergeSpider

  @name = "approve_user_spider"
  @engine = @@engine
  @start_urls = @@urls
  @config = @@config
  create_spider(@name)

  def parse(response, url:, data: {})
    sign_in_and_send_request_to(:greeter, :approve_user, "https://emergent-commons.mn.co/settings/invite/requests")
  end

  def approve_user(response, url:, data: {})
  @@limit_user_count = 50 # magic number for now -- enough to get past the unapproved users
  row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)
    scroll_to_end(row_css, "#flyout-main-content")

    first_name, last_name = get_and_clear_message.split('|')
    logger.info "> APPROVING #{first_name} #{last_name}"
    # cope with names that have an apostrophe in them
    # NOTE: for some reason, "/\/\'" results in //' not \\' which is what's needed
    first_name = first_name.gsub(/'/, "/\\/'").gsub("/", "")
    last_name = last_name.gsub(/'/, "/\\/'").gsub("/", "")

    ############################################
    # wait until the modal dialog box is visible
    css = ".invite-list-container tr.invite-request-list-item"
    wait_until(css)

    ############################################
    # see if user has already joined (database out of sync with MN database)
    has_first_name_td = first_name == "--" ? "" : ":has(td.invite-list-item-first-name[title='#{first_name}'])"
    has_last_name_td = last_name == "--" ? "" : ":has(td.invite-list-item-last-name[title='#{last_name}'])"
    css_row = "#{css}#{has_first_name_td}#{has_last_name_td}"
    css_status = "#{css_row} .invite-list-item-status-text"
    return get_member_id(css_row) if response_has(css_status, "Joined!")
    
    ############################################
    # NB: do not approve except in production!
    return set_result("1") unless Rails.env.production?

    ############################################
    # find approve button for this user
    css_approve = "#{css_row} a.invite-list-item-approve-button"
    logger.debug "> LOOKING FOR #{css_approve}"
    wait_until(css_approve)
    return unless Rails.env.production?

    browser.find(:css, css_approve).click
    wait_until(css_status, "Joined!")

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
    set_message(member_id)
  end

  ##################################################
  ## SCROLLING
  def scroll_to_end(css, modal_css)
    new_count = 0
    prev_count = browser.current_response.css(css).count
    logger.debug "> SCROLLING TO #{@@limit_user_count} ROWS ..."

    return prev_count if prev_count == 0 || (@@limit_user_count > 0 && prev_count >= @@limit_user_count)
    
    loop do
      if modal_css
        browser.execute_script("$('#{modal_css}')[0].scrollBy(0,10000)")
      else
        browser.execute_script("window.scrollBy(0,10000)")
      end

      logger.debug "> WAITING FOR NEW ROW COUNT ..."
      for i in 0..20
        break if browser.current_response.css(css).count > prev_count
        sleep 1
      end
      break if browser.current_response.css(css).count == prev_count

      new_count = browser.current_response.css(css).count
      logger.info "> INFINITE SCROLLING: prev_count = #{prev_count}; new_count = #{new_count}"
      prev_count = new_count
      break if @@limit_user_count > 0 && new_count >= @@limit_user_count
    end

    new_count
  end

  def scroll_back_to_beginning(count, modal_css)
    for i in 0..count.to_i
      if modal_css
        browser.execute_script("$('#{modal_css}')[0].scrollBy(0,-10000)")
      else
        browser.execute_script("window.scrollBy(0,-10000)")
      end
    end
  end
end
