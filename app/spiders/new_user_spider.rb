require 'emerge_spider'

class NewUserSpider < EmergeSpider
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "new_user_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://emergent-commons.mn.co/sign_in"]
  @config = {
    user_agent: USER_AGENT,
    disable_images: true,
    window_size: [1366, 768],
    user_data_dir: Rails.root.join('shared', 'tmp', 'browser_profile').to_s,
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
  @@limit_user_count = nil
  ::Spider.create(name: @name) unless ::Spider.find_by_name(@name)

  ##################################################
  ## PARSE
  def parse(response, url:, data: {})
    NewUserSpider.logger.info "SPIDER #{name} STARTING"
    request_to(:sign_in, url: "https://emergent-commons.mn.co/sign_in") unless response_has("body.communities-app")

    @@limit_user_count = ::Spider.get_message(name).to_i || 100
    method = @@limit_user_count == 0 ? :parse_all_join_requests : :parse_new_join_requests
    request_to method, url: "https://emergent-commons.mn.co/settings/invite/requests"

    ::Spider.set_result(name, "success")
    ApproveUserSpider.logger.info "#{name} COMPLETED SUCCESSFULLY"
  rescue => error
    ::Spider.set_result(name, "failure")
    ApproveUserSpider.logger.fatal "#{name} COMPLETED FAILURE: #{error.message}"
  end

  ##################################################
  ## PARSE NEW
  def parse_new_join_requests(response, url:, data: {})
    NewUserSpider.logger.debug "LOOKING FOR NEW JOIN REQUESTS"
    row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)

    @@new_user_count = scroll_to_end(row_css, "#flyout-main-content")
    rows = browser.current_response.css(row_css)
    users = []
    rows.each do |row|
      u_hash = extract_user_hash(row)
      next if u_hash.blank?
      user = User.find_by_email(u_hash[:email])
      next if user && (user.member_id || user.status == u_hash[:status])
      users.push u_hash
      sleep 1
    end
    create_or_update_users(users)
  end

  ##################################################
  ## PARSE ALL
  def parse_all_join_requests(response, url:, data: {})
    NewUserSpider.logger.debug "GETTING ALL JOIN REQUESTS"
    row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)

    @@new_user_count = scroll_to_end(row_css, "#flyout-main-content")
    scroll_back_to_beginning(@@new_user_count/25, "#flyout-main-content")
    NewUserSpider.logger.info "CRAWLING THROUGH #{@@new_user_count} MEMBERS"
    
    rows = browser.current_response.css(row_css)
    # ref https://til.hashrocket.com/posts/2dab9b4db4-ruby-array-shortcuts-and-method
    create_or_update_users rows.collect(&method(:extract_user_hash)).select(&:present?)
  end

  ##################################################
  ## EXTRACT USER DATA
  def extract_user_hash(row)
    # skip if this user exists in the database with member_id or was rejected
    email = row.css(".invite-list-item-email-text").text.strip
    user = User.find_by_email(email)
    return if user && (user.member_id || user.status == "Request Declined")

    # member is not in our database or has not joined yet and is not rejected
    first_name = row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text").text.strip
    last_name = row.css(".invite-list-item-last-name-text").text.strip
    full_name = "#{first_name} #{last_name}"
    request_date = row.css(".invite-list-item-last-updated").text.strip

    id = row.get_attribute("data-id").strip # returns the id string
    css = "tr.invite-request-list-item[data-id='#{id}']"
    NewUserSpider.logger.debug "LOOKING AT USER #{full_name}"
    NewUserSpider.logger.debug "LOOKING FOR CSS = #{css}"

    status = row.css(".invite-list-item-status-text").text.strip
    joined = ("Joined!" == status)

    if joined
      # profile_url = https://emergent-commons.mn.co/members/7567995
      profile_url = row.css(".invite-list-item-email a").attr("href").value
      member_id = profile_url.split('/').last.to_i
      chat_url = "https://emergent-commons.mn.co/chats/new?user_id=#{member_id}"
      # for joined users, do a little more to get to their answers:
      NewUserSpider.logger.debug "ATTEMPTING HOVER"
      # browser.save_screenshot
      script = "$(\"#{css}\")[0].scrollIntoView(false)"
      NewUserSpider.logger.debug "script = #{script}"
      begin
        browser.execute_script(script)
        browser.find(:css, css).hover
        # browser.save_screenshot
        NewUserSpider.logger.debug "ATTEMPTING TO OPEN DROP DOWN MENU"
        css += " a.mighty-drop-down-toggle"
        browser.find(:css, css).click
        # browser.save_screenshot
        NewUserSpider.logger.debug "ATTEMPTING TO OPEN MODAL"
        css = ".mighty-drop-down-items-container a.mighty-menu-list-item[name='menu-list-item-answers']"
        browser.find(:css, css).click
        # browser.save_screenshot
      rescue => error
        # skip this member but output an error message in the log
        NewUserSpider.logger.fatal "#{name} failed to open Answers modal: #{error}"
        NewUserSpider.logger.fatal "member #{full_name}"
        NewUserSpider.logger.fatal "css #{css}"
        NewUserSpider.logger.fatal "skipping user ------------------------------------"
        return {}
      end
    else
      chat_url = profile_url = member_id = nil
      if status == "Pending"
        # for pending requests, just click the handy "View Answers" button
        css += " td.invite-list-item-status a.invite-list-item-view-answers-button"
        NewUserSpider.logger.debug "CLICKING THE VIEW ANSWER BUTTON"
        begin
          browser.find(:css, css).click
        rescue
          # skip this member but output an error message in the log
          NewUserSpider.logger.fatal "#{name} failed to click View Answers button: #{error}"
          NewUserSpider.logger.fatal "member #{full_name}"
          NewUserSpider.logger.fatal "css #{css}"
          NewUserSpider.logger.fatal "skipping user ------------------------------------"
          return {}
        end
      end
    end

    questions_and_answers = parse_questions_and_answers

    NewUserSpider.logger.debug "ATTEMPTING TO CLOSE MODAL"
    css = ".modal-form-container-header a.modal-form-container-left-button"
    begin
      browser.find(:css, css).click
      # browser.save_screenshot
    rescue
      # skip this member but output an error message in the log
      NewUserSpider.logger.fatal "#{name} failed to close Answers modal: #{error}"
      NewUserSpider.logger.fatal "member #{full_name}"
      NewUserSpider.logger.fatal "css #{css}"
      NewUserSpider.logger.fatal "skipping user ------------------------------------"
      return {}
    end

    NewUserSpider.logger.debug "\n\n-------------------------------------------------------"
    NewUserSpider.logger.debug "name = #{full_name}"
    NewUserSpider.logger.debug "email = #{email}"
    NewUserSpider.logger.debug "request_date = #{request_date}"
    NewUserSpider.logger.debug "status = #{status}"
    NewUserSpider.logger.debug "joined = #{joined}"
    NewUserSpider.logger.debug "member_id = #{member_id}"
    NewUserSpider.logger.debug "profile_url = #{profile_url}"
    NewUserSpider.logger.debug "chat_url = #{chat_url}"
    NewUserSpider.logger.debug "qna = #{questions_and_answers.join("\n\n")}"

    {
      name: full_name,
      first_name: first_name,
      last_name: last_name,
      email: email.downcase,
      profile_url: profile_url,
      chat_url: chat_url,
      member_id: member_id,
      request_timestamp: request_date,
      status: "Joined!" == status ? "Scheduling Zoom" : status,
      questions_responses: questions_and_answers.join(" -:- "),
      joined: joined
    }
  end

  ##################################################
  ## EXTRACT QUESTIONS AND ANSWERS
  def parse_questions_and_answers
    css = ".invite-request-answers"
    wait_until(css)
    css += " ol li"
    browser.current_response.css(css).collect do |li|
      question = li.css(".invite-request-answer-question").text
      answer = li.css(".invite-request-answer-response").text
      "#{question}\\#{answer}"
    end
  end

  ##################################################
  ## CREATE OR UPDATE USERS
  def create_or_update_users(users)
    users.each do |u|
      user = User.find_by_email(u[:email])
      if user
        NewUserSpider.logger.info "updating user: #{u[:name]}"
        user.profile_url = u[:profile_url] unless user.profile_url
        user.chat_url = u[:chat_url] unless user.chat_url
        user.status = u[:status] if user.status == "Pending"
        user.joined = u[:joined] unless user.joined
        user.save
      else
        NewUserSpider.logger.info "creating user: #{u[:name]}"
        User.create!(u) unless user
      end
    rescue => error
      logger.fatal "ERROR in new_user_spider#create_or_update_users: #{error.message}"
    end
  end

  ##################################################
  ## SCROLLING
  def scroll_to_end(css, modal_css)
    new_count = 0
    prev_count = browser.current_response.css(css).count
    NewUserSpider.logger.debug "#{name} SCROLLING TO #{@@limit_user_count} ROWS ..."

    return prev_count if prev_count == 0 || (@@limit_user_count > 0 && prev_count >= @@limit_user_count)
    
    loop do
      if modal_css
        browser.execute_script("$('#{modal_css}')[0].scrollBy(0,10000)")
      else
        browser.execute_script("window.scrollBy(0,10000)")
      end

      NewUserSpider.logger.debug "#{name} WAITING FOR NEW ROW COUNT ..."
      for i in 0..20
        break if browser.current_response.css(css).count > prev_count
        sleep 1
      end
      break if browser.current_response.css(css).count == prev_count

      new_count = browser.current_response.css(css).count
      NewUserSpider.logger.info "INFINITE SCROLLING: prev_count = #{prev_count}; new_count = #{new_count}"
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
