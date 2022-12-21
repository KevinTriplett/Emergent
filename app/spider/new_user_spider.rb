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
      delay: 2..4
    }
  }
  @@limit_user_count = nil
  ::Spider.create(name: @name) unless ::Spider.find_by_name(@name)

  def parse(response, url:, data: {})
    NewUserSpider.logger.info "SPIDER #{name} STARTING"
    request_to(:sign_in, url: "https://emergent-commons.mn.co/sign_in") unless response_has("body.communities-app")

    @@limit_user_count = ::Spider.get_message(name).to_i || 100
    request_to :parse_join_requests, url: "https://emergent-commons.mn.co/settings/invite/requests"

    ::Spider.set_result(name, "success")
    ApproveUserSpider.logger.info "#{name} COMPLETED SUCCESSFULLY"
  end

  def parse_join_requests(response, url:, data: {})
    NewUserSpider.logger.debug "LOOKING FOR NEW JOIN REQUESTS"
    row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)
    @@new_user_count = scroll_to_end(row_css, "#flyout-main-content")
    scroll_back_to_beginning(@@new_user_count/25, "#flyout-main-content")
    NewUserSpider.logger.info "CRAWLING THROUGH #{@@new_user_count} MEMBERS"
    
    users = []
    browser.current_response.css(row_css).each_with_index do |row, idx|

      # name = [
      #   row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text"),
      #   row.css(".invite-list-item-last-name-text")
      # ].map(&:text).join(" ")
      first_name = row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text").text.strip
      last_name = row.css(".invite-list-item-last-name-text").text.strip
      full_name = "#{first_name} #{last_name}"
      email = row.css(".invite-list-item-email-text").text.strip
      request_date = row.css(".invite-list-item-email + td").text.strip

      id = row.get_attribute("data-id").strip # returns the id string
      css = "tr.invite-request-list-item[data-id='#{id}']"
      NewUserSpider.logger.debug "css = #{css}"

      if row.css("a.invite-list-item-status-text").count == 0
        status = "Pending"
        chat_url = profile_url = member_id = nil
        # for new requests, just click the nice button
        css += " td.invite-list-item-status a.invite-list-item-view-answers-button"
        NewUserSpider.logger.debug "CLICKING THE ANSWER BUTTON"
        begin
          browser.find(:css, css).click
        rescue
          # skip this member but output a message in the log
          NewUserSpider.logger.fatal "#{name} could not click on Answer button"
          NewUserSpider.logger.fatal "member #{full_name}"
          NewUserSpider.logger.fatal "css #{css}"
          NewUserSpider.logger.fatal "skipping ------------------------------------"
          next
        end
      else
        status = row.css("a.invite-list-item-status-text").text.strip
        profile_url = row.css(".invite-list-item-email a").attr("href").value
        # https://emergent-commons.mn.co/members/7567995
        member_id = profile_url.split('/').last.to_i
        chat_url = "https://emergent-commons.mn.co/chats/new?user_id=#{member_id}"
        # for joined users, do a little more to get to their answers:
        NewUserSpider.logger.debug "ATTEMPTING HOVER"
        # browser.save_screenshot
        script = "$(\"#{css}\")[0].scrollIntoView(false)"
        NewUserSpider.logger.debug "script = #{script}"
        browser.execute_script(script) rescue break
        browser.find(:css, css).hover rescue break
        # browser.save_screenshot
        sleep 1
        NewUserSpider.logger.debug "ATTEMPTING TO OPEN DROP DOWN MENU"
        css += " a.mighty-drop-down-toggle"
        browser.find(:css, css).click rescue break
        # browser.save_screenshot
        sleep 1
        NewUserSpider.logger.debug "ATTEMPTING TO OPEN MODAL"
        css = ".mighty-drop-down-items-container a.mighty-menu-list-item[name='menu-list-item-answers']"
        browser.find(:css, css).click rescue break
        # browser.save_screenshot
      end

      sleep 1

      questions_and_answers = parse_questions_and_answers

      NewUserSpider.logger.debug "ATTEMPTING TO CLOSE MODAL"
      css = ".modal-form-container-header a.modal-form-container-left-button"
      browser.find(:css, css).click rescue break
      # browser.save_screenshot

      sleep 1

      NewUserSpider.logger.debug "\n\n-------------------------------------------------------"
      NewUserSpider.logger.debug "MEMBER #{users.count + 1} of #{@@new_user_count}"
      NewUserSpider.logger.debug "name = #{full_name}"
      NewUserSpider.logger.debug "email = #{email}"
      NewUserSpider.logger.debug "request_date = #{request_date}"
      NewUserSpider.logger.debug "status = #{status}"
      NewUserSpider.logger.debug "member_id = #{member_id}"
      NewUserSpider.logger.debug "profile_url = #{profile_url}"
      NewUserSpider.logger.debug "chat_url = #{chat_url}"
      NewUserSpider.logger.debug "qna = #{questions_and_answers.join("\n\n")}"

      users.push({
        name: full_name,
        first_name: first_name,
        last_name: last_name,
        email: email,
        profile_url: profile_url,
        chat_url: chat_url,
        member_id: member_id,
        request_timestamp: request_date,
        status: status,
        questions_responses: questions_and_answers.join(" -:- ")
      })
    end

    create_users(users)
  end

  def parse_questions_and_answers
    sleep 1
    css = ".invite-request-answers"
    wait_until(css)
    css += " ol li"
    browser.current_response.css(css).collect do |li|
      question = li.css(".invite-request-answer-question").text
      answer = li.css(".invite-request-answer-response").text
      "#{question}\\#{answer}"
    end
  end

  def create_users(users)
    users.each do |u|
      user = User.find_by_email(u[:email])
      logger.info((user ? "updating " : "creating ") + u[:name])
      user.update(profile_url: u[:profile_url]) if user
      user.update(chat_url: u[:chat_url]) if user
      User.create!(u) unless user
    rescue => error
      logger.fatal "ERROR in new_user_spider#create_users: #{error.message}"
      next
    end
  end

  def scroll_to_end(css, modal_css)
    prev_count = browser.current_response.css(css).count
    return prev_count if prev_count == 0 || (@@limit_user_count > 0 && prev_count >= @@limit_user_count)
    new_count = 0
    
    loop do
      if modal_css
        browser.execute_script("$('#{modal_css}')[0].scrollBy(0,10000)")
      else
        browser.execute_script("window.scrollBy(0,10000)")
      end
      sleep 10
      new_count = browser.current_response.css(css).count
      NewUserSpider.logger.info "INFINITE SCROLLING: prev_count = #{prev_count}; new_count = #{new_count}"
      break if new_count == prev_count || (@@limit_user_count > 0 && new_count >= @@limit_user_count)
      prev_count = new_count
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
