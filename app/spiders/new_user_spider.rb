require 'emerge_spider'

class NewUserSpider < EmergeSpider
  @name = "new_user_spider"
  @engine = @@engine
  @start_urls = @@urls
  @config = @@config
  create_spider(@name)
  @@limit_user_count = nil

  ##################################################
  ## PARSE
  def parse(response, url:, data: {})
    @@limit_user_count = get_and_clear_message.to_i || 100
    sign_in_and_send_request_to(:greeter, :parse_members, "https://emergent-commons.mn.co/settings/invite/requests")
  end

  ##################################################
  ## PARSE NEW
  def parse_members(response, url:, data: {})
    logger.debug "> LOOKING FOR NEW JOIN REQUESTS"
    row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)
    @@new_user_count = scroll_to_end(row_css, "#flyout-main-content")

    # acknowledge cookies
    browser.find(:css, "#gdpr-cookie-accept").click if response_has("#gdpr-cookie-accept")

    # MN is cloaking member emails so reveal emails
    logger.info "> MAKING EMAILS VISIBLE"
    begin
      browser.find(:css, ".invite-list-container thead .email-visibility-toggle").click
      wait_until(".confirmation-modal-container .modal-confirm-button")
      sleep 1
      browser.find(:css, ".confirmation-modal-container .modal-confirm-button").click
      sleep 1
    rescue => error
      logger.info "> COULD NOT REVEAL EMAIL BECAUSE: #{error}"
    end
    
    # now check row-by-row for new users and missing information
    rows = browser.current_response.css(row_css)
    rows.each do |row|
      u_hash = exfiltrate_user_hash(row)
      next if u_hash.blank?
      create_or_update_user(u_hash)
    end
  end

  ##################################################
  ## EXTRACT USER DATA
  def exfiltrate_user_hash(row)
    status = row.css(".invite-list-item-status-text").text.strip
    joined = "Joined!" == status
    member_id = get_member_id(row)
    email = row.css(".invite-list-item-email-text").text.strip
    email = nil if email == "--"
    if email && email.match(/\*{3}/) # emails are cloaked with asterisks
      raise EmailCloaked
    end
    first_name = row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text").text.strip
    last_name = row.css(".invite-list-item-last-name-text").text.strip
    full_name = "#{first_name} #{last_name}"
    request_date = row.css(".invite-list-item-last-updated").text.strip
    logger.debug "> LOOKING AT USER #{full_name}"

    # users can be in one of three states:
    #   user not in database
    #     scrap name, email and answers to questions into hash for later db write
    #     may have been approved using MN platform
    #   user in database but not approved yet (not joined)
    #     skip since we already have all the information we can get
    #   member_id or answers to questions not yet recorded in database
    #     update member_id, profile_url and chat_url
    #     update status and joined flag
    #     update answers to questions in db
    #   member_id and answers to questions already recorded in database
    #     skip since we already have all the information we can get

    user = find_user_by_user_hash({
      member_id: member_id,
      email: email,
      name: full_name
    })

    #   member_id in database
    #     skip since we already have all the information we can get
    if user && (user.member_id || "Request Declined" == user.status) && !user.questions_responses.blank?
      logger.debug ">   SKIP #{full_name} BECAUSE ALREADY IN DATABASE WITH member_id" if user.member_id
      logger.debug ">   SKIP #{full_name} BECAUSE PREVIOUSLY DECLINED" if "Request Declined" == user.status
      return
    end

    if user && !member_id && !user.questions_responses.blank?
      logger.debug ">   SKIP #{full_name} BECAUSE IN DATABASE BUT NOT JOINED YET"
      return
    end

    #   member_id not yet captured in database (capture member_id)
    #     update member_id, profile_url and chat_url
    #     update status and joined flag
    # profile_url has pattern https://emergent-commons.mn.co/members/7567995
    # chat_url has pattern https://emergent-commons.mn.co/chats/new?user_id=7567995
    profile_url = member_id ? "https://emergent-commons.mn.co/members/#{member_id}" : nil
    chat_url = member_id ? "https://emergent-commons.mn.co/chats/new?user_id=#{member_id}" : nil

    begin
      questions_and_answers = get_questions_and_answers(joined, row) if !user || user.questions_responses.blank?
    rescue => error
      # skip this member but output an error message in the log
      logger.fatal "> skipping user ------------------------------------"
      logger.fatal "> for member #{full_name}"
      logger.fatal "> failed to open Answers modal:"
      logger.fatal "> #{error}"
      logger.fatal "> skipping user ------------------------------------"
    end

    logger.debug "> \n\n-------------------------------------------------------"
    logger.debug "> Adding name = #{full_name}"
    logger.debug "> email = #{email}"
    logger.debug "> request_date = #{request_date}"
    logger.debug "> status = #{status}"
    logger.debug "> joined = #{joined}"
    logger.debug "> member_id = #{member_id}"
    logger.debug "> profile_url = #{profile_url}"
    logger.debug "> chat_url = #{chat_url}"
    logger.debug "> qna = #{(questions_and_answers || []).join("\n\n")}"

    {
      name: full_name,
      first_name: first_name,
      last_name: last_name,
      email: email,
      profile_url: profile_url,
      chat_url: chat_url,
      member_id: member_id,
      request_timestamp: request_date,
      status: joined ? "Scheduling Zoom" : status,
      questions_responses: (questions_and_answers || []).join(" -:- "),
      joined: joined
    }
  end

  ##################################################
  ## EXTRACT EMAIL AND MEMBER_ID AND ANSWERS TO QUESTIONS
  def get_email(row)
    text = row.css(".invite-list-item-email-text").text.strip
    text.blank? ? nil : text.downcase
  end

  def get_member_id(row)
    href = row.css(".invite-list-item-last-name-text a").attr("href")
    href.blank? ? nil : href.value.split('/').last.to_i
  end

  def get_questions_and_answers(joined, row)
    questions_and_answers = nil

    row_id = row.attr("data-id") # returns the id string
    css = "[data-id='#{row_id}']"

    if joined
      #   user not in database but has a member_id (may have been approved using MN platform)
      #     scrap answers to questions
      #     requires a little more to get to their answers than non-joined members
      logger.debug "> ATTEMPTING ANSWERS HOVER"
      # browser.save_screenshot
      browser.find(:css, css).hover
      # browser.save_screenshot
      logger.debug "> ATTEMPTING TO OPEN DROP DOWN MENU"
      css += " a.mighty-drop-down-toggle"
      browser.find(:css, css).click
      # browser.save_screenshot
      logger.debug "> ATTEMPTING TO OPEN MODAL"
      css = ".mighty-drop-down-items-container a.mighty-menu-list-item[name='menu-list-item-answers']"
    else
      #   user not in database and not approved yet
      #     for pending requests, just click the handy "View Answers" button
      #     scrap answers to questions
      css += " td.invite-list-item-status a.invite-list-item-view-answers-button"
      logger.debug "> CLICKING THE VIEW ANSWER BUTTON"
    end

    # browser.save_screenshot
    browser.find(:css, css).click
    sleep 1
    # browser.save_screenshot
    questions_and_answers = parse_questions_and_answers
    logger.debug "> ATTEMPTING TO CLOSE MODAL"
    css = ".modal-form-container-header a.modal-form-container-left-button"
    browser.find(:css, css).click
    # browser.save_screenshot
    questions_and_answers
  end

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
  ## CREATE OR DELETE OR UPDATE USER
  def create_or_update_user(u_hash)
    user = find_user_by_user_hash(u_hash)
    if user
      logger.info "> updating user: #{user.name}"
      user.member_id ||= u_hash[:member_id]
      user.profile_url ||= u_hash[:profile_url]
      user.chat_url ||= u_hash[:chat_url]
      user.status = u_hash[:status] if u_hash[:status] && user.status == "Pending"
      user.joined = u_hash[:joined] unless user.joined
      user.questions_responses = u_hash[:questions_responses] if user.questions_responses.blank?
      user.save!
    else
      logger.info "> creating user: #{u_hash[:name]}"
      User.create!(u_hash)
    end
  rescue => error
    logger.fatal "> ERROR in new_user_spider#create_or_update_user: #{error.message}"
  end

  def find_user_by_user_hash(u_hash)
    (u_hash[:member_id] && User.find_by_member_id(u_hash[:member_id])) ||
    (u_hash[:email] && User.find_by_email(u_hash[:email])) ||
    (User.where(name: u_hash[:name]).and(User.where("request_timestamp > ?", Time.now - 3.month)).first)
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
