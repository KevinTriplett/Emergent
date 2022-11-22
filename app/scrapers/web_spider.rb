require 'kimurai'

class WebSpider < Kimurai::Base
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36"
  @name = "spider"
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
      delay: 2..4
    }
  }

  def parse(response, url:, data: {})
    sign_in
    report_failure_unless_response_has("body.communities-app")
    # browser.save_screenshot
    request_to :parse_requests_to_join, url: "https://emergent-commons.mn.co/settings/invite/requests"
    # browser.save_screenshot
  end

  # TODO: fill in missing information for members after they join
  def parse_requests_to_join(response, url:, data: {})
    row_css = ".invite-list-container tr.invite-request-list-item"
    wait_until(row_css)
    scroll_to_end(row_css, ".invite-list-container")
    
    members = []
    browser.current_response.css(row_css).each_with_index do |row, idx|
      # name = [
      #   row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text"),
      #   row.css(".invite-list-item-last-name-text")
      # ].map(&:text).join(" ")
      first_name = row.css(".invite-list-item-first-name .ext, .invite-list-item-first-name-text").text.strip
      last_name = row.css(".invite-list-item-last-name-text").text.strip
      # puts "name = #{name}"
      name = "#{first_name} #{last_name}"
      puts "name = #{name}"
      email = row.css(".invite-list-item-email-text").text.strip
      puts "email = #{email}"
      request_date = row.css(".invite-list-item-email + td").text.strip
      puts "request_date = #{request_date}"
      status = row.css(".invite-list-item-status-text").text.strip
      puts "status = #{status}"

      profile_url = (status == "Joined!") ?
        row.css(".invite-list-item-email a").attr("href") :
        nil
      puts "profile_url = #{profile_url}"
      
      id = row.get_attribute("data-id").strip # returns the id string
      # puts "tr data-id = #{id}"
      # puts "ATTEMPTING HOVER"
      # browser.save_screenshot
      css = "tr.invite-request-list-item[data-id='#{id}']"
      # puts "css = #{css}"
      browser.find(:css, css).hover
      # browser.save_screenshot
      
      # puts "ATTEMPTING TO OPEN DROP DOWN MENU"
      css += " a.mighty-drop-down-toggle"
      browser.find(:css, css).click
      # browser.save_screenshot
      
      # puts "ATTEMPTING TO OPEN MODAL"
      css = ".mighty-drop-down-items-container a.mighty-menu-list-item[name='menu-list-item-answers']"
      browser.find(:css, css).click
      # browser.save_screenshot

      questions_and_answers = parse_questions_and_answers
      puts "qna = #{questions_and_answers.join("\n\n")}"

      # puts "ATTEMPTING TO CLOSE MODAL"
      browser.find(:css, ".modal-form-container-header a.modal-form-container-left-button").click
      # browser.save_screenshot
      sleep 1

      puts "\n-------------------------------------------------------\n"
      members.push({
        name: name,
        email: email,
        profile_url: profile_url,
        request_timestamp: request_date,
        status: status,
        questions_responses: questions_and_answers,
      })
    end

    create_members(members)
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

  def create_members(members)
    members.each do |member|
      next if Member.find_by_email(member[:email])
      puts "SAVING #{member[:name]}"
      Member.create! member
    end
  end

  def scroll_to_end(css, modal_css = nil)
    prev_count = browser.current_response.css(css).count
    return if prev_count == 0
    
    loop do
      modal_css ?
        browser.find(:css, modal_css).scroll_to(:bottom, [0,10000]) :
        browser.execute_script("window.scrollBy(0,10000)")
      sleep 4
      new_count = browser.current_response.css(css).count
      puts "INFINITE SCROLLING: prev_count = #{prev_count}; new_count = #{new_count}"
      break if new_count == prev_count
      prev_count = new_count
    end

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
