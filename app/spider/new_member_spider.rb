require 'kimurai'

class NewMemberSpider < Kimurai::Base
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "new_member_spider"
  @engine = :selenium_chrome
  @start_urls = ["https://emergent-commons.mn.co/sign_in"]
  @new_member_count = 0
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

  def parse(response, url:, data: {})
    sign_in
    report_failure_unless_response_has("body.communities-app")
    # browser.save_screenshot
    request_to :parse_requests_to_join, url: "https://emergent-commons.mn.co/settings/invite/requests"
    # browser.save_screenshot
    puts "ALL DONE SUCCESSFULLY"
  end

  # TODO: fill in missing information for users after they join
  def parse_requests_to_join(response, url:, data: {})
    puts "LOOKING FOR NEW JOIN REQUESTS"
    row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)
    @new_member_count = scroll_to_end(row_css, "#flyout-main-content")
    
    users = []
    browser.current_response.css(row_css).each_with_index do |row, idx|

      # name = [
      #   row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text"),
      #   row.css(".invite-list-item-last-name-text")
      # ].map(&:text).join(" ")
      first_name = row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text").text.strip
      last_name = row.css(".invite-list-item-last-name-text").text.strip
      name = "#{first_name} #{last_name}"
      email = row.css(".invite-list-item-email-text").text.strip
      request_date = row.css(".invite-list-item-email + td").text.strip

      id = row.get_attribute("data-id").strip # returns the id string
      css = "tr.invite-request-list-item[data-id='#{id}']"
      # puts "css = #{css}"

      if row.css("a.invite-list-item-status-text").count == 0
        status = "Pending"
        profile_url = nil
        # for new requests, just click the nice button
        css += " td.invite-list-item-status a.invite-list-item-view-answers-button"
        # puts "CLICKING THE ANSWER BUTTON"
        browser.find(:css, css).click
      else
        status = row.css("a.invite-list-item-status-text").text.strip
        profile_url = row.css(".invite-list-item-email a").attr("href")
        # for joined members, do a little more to get to their answers:
        # puts "ATTEMPTING HOVER"
        # browser.save_screenshot
        script = "$(\"#{css}\")[0].scrollIntoView(false)"
        # puts "script = #{script}"
        browser.execute_script(script) rescue break
        browser.find(:css, css).hover rescue break
        # browser.save_screenshot
        sleep 1
        # puts "ATTEMPTING TO OPEN DROP DOWN MENU"
        css += " a.mighty-drop-down-toggle"
        browser.find(:css, css).click rescue break
        # browser.save_screenshot
        sleep 1
        # puts "ATTEMPTING TO OPEN MODAL"
        css = ".mighty-drop-down-items-container a.mighty-menu-list-item[name='menu-list-item-answers']"
        browser.find(:css, css).click rescue break
        # browser.save_screenshot
      end

      sleep 1

      questions_and_answers = parse_questions_and_answers

      # puts "ATTEMPTING TO CLOSE MODAL"
      css = ".modal-form-container-header a.modal-form-container-left-button"
      browser.find(:css, css).click rescue break
      # browser.save_screenshot

      sleep 1

      puts "\n-------------------------------------------------------\n"
      puts "MEMBER #{users.count + 1} of #{@new_member_count}"
      puts "name = #{name}"
      puts "email = #{email}"
      puts "request_date = #{request_date}"
      puts "status = #{status}"
      puts "profile_url = #{profile_url}"
      puts "qna = #{questions_and_answers.join("\n\n")}"

      users.push({
        name: name,
        email: email,
        profile_url: profile_url,
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

  def sign_in
    wait_until("body.auth-sign_in")
    puts "SIGNING IN"
    browser.fill_in "Email", with: "kt@kevintriplett.com"
    sleep 1
    browser.fill_in "Password", with: "XV9NN79P4xNbGLXPdo"
    browser.click_link "Sign In"
    sleep 1
    wait_while(".pace-running")
    puts "SUCCESS!"
  end

  def create_users(users)
    users.each_with_index do |member, member_count|
      if User.find_by_email(member[:email])
        puts "SKIPPING EXISTING MEMBER: #{member[:name]}"
        next
      end
      puts "SAVING (#{member_count} of #{@new_member_count}): #{member[:name]}"
      User.create! member
    end
  end

  def scroll_to_end(css, modal_css)
    prev_count = browser.current_response.css(css).count
    return if prev_count == 0
    
    loop do
      if modal_css
        browser.execute_script("$('#{modal_css}')[0].scrollBy(0,10000)")
      else
        browser.execute_script("window.scrollBy(0,10000)")
      end
      sleep 10
      new_count = browser.current_response.css(css).count
      puts "INFINITE SCROLLING: prev_count = #{prev_count}; new_count = #{new_count}"
      break if new_count == prev_count || new_count > 150
      prev_count = new_count
    end

    new_count
  end

  def report_failure_unless_response_has(css)
    return if response_has(css)
    puts "Expected to find #{css}"
    raise
  end

  def response_has(css)
    browser.current_response.css(css).length > 0
  end

  def wait_while(css)
    i = 10
    sleep 1
    while response_has(css) || i < 0
      puts "WAITING WHILE #{css} ..."
      sleep 1
      i -= 1
    end
    puts "NEVER WENT AWAY!" if response_has(css)
  end

  def wait_until(css)
    i = 10
    sleep 1
    until response_has(css) || i < 0
      puts "WAITING UNTIl #{css} ..."
      sleep 1
      i -= 1
    end
    puts "COULD NOT FIND IT!" unless response_has(css)
  end
end
