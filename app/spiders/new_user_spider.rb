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

  ##################################################
  ## PARSE
  def parse(response, url:, data: {})
    EmergeSpider.logger.info "SPIDER #{name} STARTING"
    request_to(:sign_in, url: "https://emergent-commons.mn.co/sign_in") unless response_has("body.communities-app")

    @@limit_user_count = get_message.to_i || 100
    request_to :parse_members, url: "https://emergent-commons.mn.co/settings/invite/requests"

    set_result("success")
    EmergeSpider.logger.info "#{name} COMPLETED SUCCESSFULLY"
  rescue => error
    set_result("failure")
    EmergeSpider.logger.fatal "#{name} COMPLETED FAILURE: #{error.message}"
  end

  ##################################################
  ## PARSE NEW
  def parse_members(response, url:, data: {})
    EmergeSpider.logger.debug "LOOKING FOR NEW JOIN REQUESTS"
    row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)

    EmergeSpider.logger.info "MAKING EMAILS VISIBLE"
    begin
      browser.find(:css, ".invite-list-container thead .email-visibility-toggle").click
      sleep 5
      browser.find(:css, ".confirmation-modal-container .modal-confirm-button").click
      sleep 1
    rescue => error
      EmergeSpider.logger.info "COULD NOT REVEAL EMAIL BECAUSE: #{error}"
    end

    @@new_user_count = scroll_to_end(row_css, "#flyout-main-content")
    rows = browser.current_response.css(row_css)
    new_users = []
    rows.each do |row|
      u_hash = extract_user_hash(row)
      next if u_hash.blank?
      # users can be in one of three states:
      #   brand new request to join (not in database at all)
      #   new request to join already in database (but not approved yet)
      #   joined but member_id not yet captured in database (capture member_id)
      #   joined with member_id in database (do nothing)
      #   in the database but not in the list of join requests (was rejected)
      # see if this user is already in the database (user cannot change name if not joined)
      existing_users = User.where(name: u_hash[:name])
      case existing_users.count
      when 0
        new_users.push u_hash
      when 1
        existing_user = existing_users.first
        next if existing_user.member_id && existing_user.joined?
        next unless u_hash[:member_id]
        existing_user.update member_id: u_hash[:member_id]
        existing_user.update profile_url: u_hash[:profile_url]
        existing_user.update chat_url: u_hash[:chat_url]
      end
      sleep 1
    end
    create_or_update_users(new_users)
    update_rejected_users(new_users)
  end

  ##################################################
  ## EXTRACT USER DATA
  def extract_user_hash(row)
    status = row.css(".invite-list-item-status-text").text.strip
    joined = ("Joined!" == status)
    email = row.css(".invite-list-item-email-text").text.strip
    if email.match /\*{3}/ # emails are cloaked with asterisks
      EmergeSpider.logger.info "EMAILS ARE CLOAKED"
      return
    end
    member_id = get_member_id(row)

    # MN is cloaking member emails so ...
    # check for existing members by member_id and do not overwrite DB email
    # pseudocode:
    #   determine new requests by MN state
    #   extract member_id
    #   



    user = User.find_by_email(email)
    return if user && (user.member_id || user.status == "Request Declined")

    # member is not in our database yet or has not joined yet and is not rejected
    first_name = row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text").text.strip
    last_name = row.css(".invite-list-item-last-name-text").text.strip
    full_name = "#{first_name} #{last_name}"
    request_date = row.css(".invite-list-item-last-updated").text.strip

    id = row.get_attribute("data-id").strip # returns the id string
    css = "tr.invite-request-list-item[data-id='#{id}']"
    EmergeSpider.logger.debug "LOOKING AT USER #{full_name}"
    EmergeSpider.logger.debug "LOOKING FOR CSS = #{css}"

    if joined && member_id
      # profile_url = https://emergent-commons.mn.co/members/7567995
      profile_url = "https://emergent-commons.mn.co/members/#{member_id}"
      chat_url = "https://emergent-commons.mn.co/chats/new?user_id=#{member_id}"
      # for joined users, do a little more to get to their answers:
      EmergeSpider.logger.debug "ATTEMPTING HOVER"
      # browser.save_screenshot
      script = "$(\"#{css}\")[0].scrollIntoView(false)"
      EmergeSpider.logger.debug "script = #{script}"
      begin
        browser.execute_script(script)
        browser.find(:css, css).hover
        # browser.save_screenshot
        EmergeSpider.logger.debug "ATTEMPTING TO OPEN DROP DOWN MENU"
        css += " a.mighty-drop-down-toggle"
        browser.find(:css, css).click
        # browser.save_screenshot
        EmergeSpider.logger.debug "ATTEMPTING TO OPEN MODAL"
        css = ".mighty-drop-down-items-container a.mighty-menu-list-item[name='menu-list-item-answers']"
        browser.find(:css, css).click
        # browser.save_screenshot
      rescue => error
        # skip this member but output an error message in the log
        EmergeSpider.logger.fatal "#{name} failed to open Answers modal: #{error}"
        EmergeSpider.logger.fatal "member #{full_name}"
        EmergeSpider.logger.fatal "css #{css}"
        EmergeSpider.logger.fatal "skipping user ------------------------------------"
        return {}
      end
    else
      chat_url = profile_url = member_id = nil
      if status == "Pending"
        # for pending requests, just click the handy "View Answers" button
        css += " td.invite-list-item-status a.invite-list-item-view-answers-button"
        EmergeSpider.logger.debug "CLICKING THE VIEW ANSWER BUTTON"
        begin
          browser.find(:css, css).click
        rescue
          # skip this member but output an error message in the log
          EmergeSpider.logger.fatal "#{name} failed to click View Answers button: #{error}"
          EmergeSpider.logger.fatal "member #{full_name}"
          EmergeSpider.logger.fatal "css #{css}"
          EmergeSpider.logger.fatal "skipping user ------------------------------------"
          return {}
        end
      end
    end

    questions_and_answers = parse_questions_and_answers

    EmergeSpider.logger.debug "ATTEMPTING TO CLOSE MODAL"
    css = ".modal-form-container-header a.modal-form-container-left-button"
    begin
      browser.find(:css, css).click
      # browser.save_screenshot
    rescue
      # skip this member but output an error message in the log
      EmergeSpider.logger.fatal "#{name} failed to close Answers modal: #{error}"
      EmergeSpider.logger.fatal "member #{full_name}"
      EmergeSpider.logger.fatal "css #{css}"
      EmergeSpider.logger.fatal "skipping user ------------------------------------"
      return {}
    end

    EmergeSpider.logger.debug "\n\n-------------------------------------------------------"
    EmergeSpider.logger.debug "name = #{full_name}"
    EmergeSpider.logger.debug "email = #{email}"
    EmergeSpider.logger.debug "request_date = #{request_date}"
    EmergeSpider.logger.debug "status = #{status}"
    EmergeSpider.logger.debug "joined = #{joined}"
    EmergeSpider.logger.debug "member_id = #{member_id}"
    EmergeSpider.logger.debug "profile_url = #{profile_url}"
    EmergeSpider.logger.debug "chat_url = #{chat_url}"
    EmergeSpider.logger.debug "qna = #{questions_and_answers.join("\n\n")}"

    {
      name: full_name,
      first_name: first_name,
      last_name: last_name,
      email: email,
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
  ## EXTRACT EMAIL AND MEMBER_ID
  def get_email(row)
    text = row.css(".invite-list-item-email-text").text.strip
    text.blank? ? nil : text.downcase
  end
  def get_member_id(row)
    href = row.css(".invite-list-item-last-name-text a").attr("href")
    href.blank? ? nil : href.value.split('/').last.to_i
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
  ## CREATE OR DELETE OR UPDATE USERS
  def create_or_update_users(users)
    users.each do |u|
      user = User.find_by_email(u[:email])
      if user
        EmergeSpider.logger.info "updating user: #{u[:name]}"
        user.profile_url = u[:profile_url] unless user.profile_url
        user.chat_url = u[:chat_url] unless user.chat_url
        user.status = u[:status] if user.status == "Pending"
        user.joined = u[:joined] unless user.joined
        user.save
      else
        EmergeSpider.logger.info "creating user: #{u[:name]}"
        User.create!(u) unless user
      end
    rescue => error
      logger.fatal "ERROR in new_user_spider#create_or_update_users: #{error.message}"
    end
  end

  def update_rejected_users(users)
    user_emails = users.map(&:email)
    User.where(joined: false).each do |user|
      next user_emails.index(user.email)
      # user no longer on MN request to join list
      user.update status: "Request Declined"
    end
  end

  ##################################################
  ## SCROLLING
  def scroll_to_end(css, modal_css)
    new_count = 0
    prev_count = browser.current_response.css(css).count
    EmergeSpider.logger.debug "#{name} SCROLLING TO #{@@limit_user_count} ROWS ..."

    return prev_count if prev_count == 0 || (@@limit_user_count > 0 && prev_count >= @@limit_user_count)
    
    loop do
      if modal_css
        browser.execute_script("$('#{modal_css}')[0].scrollBy(0,10000)")
      else
        browser.execute_script("window.scrollBy(0,10000)")
      end

      EmergeSpider.logger.debug "#{name} WAITING FOR NEW ROW COUNT ..."
      for i in 0..20
        break if browser.current_response.css(css).count > prev_count
        sleep 1
      end
      break if browser.current_response.css(css).count == prev_count

      new_count = browser.current_response.css(css).count
      EmergeSpider.logger.info "INFINITE SCROLLING: prev_count = #{prev_count}; new_count = #{new_count}"
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
