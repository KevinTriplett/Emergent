require 'emerge_spider'

class SurveyInviteSpider < EmergeSpider
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

    survey_invites = SurveyInvite.queued
    survey_invites.each do |si|
      @@user = si.user
      @@survey = si.survey
      @@survey_invite = si
      ApproveUserSpider.logger.info "SENDING INVITE TO #{@@user.name} FOR #{@@survey.name}"
      request_to(:send_invite, url: @@user.chat_url)
      si.update(sent_timestamp: Time.now)
    end
    ApproveUserSpider.logger.info "#{name} COMPLETED SUCCESSFULLY"
  rescue => error
    ::Spider.set_result(name, "failure")
    ApproveUserSpider.logger.fatal "#{name} #{error.class}: #{error.message}"
  end

  def send_invite(response, url:, data: {})
    wait_until(".universal-input-form-body-container .fr-element.fr-view")
    browser.find(:css, ".universal-input-form-body-container .fr-element.fr-view").click
    browser.send_keys(@@survey_invite.subject)
    browser.send_keys [:enter]
    sleep 1
    browser.send_keys(@@survey_invite.body)
    browser.send_keys [:enter]
    sleep 1
    url = survey_invite_url(token: @@survey.token)
    browser.send_keys(url)
    browser.send_keys [:enter]
    sleep 1
    browser.send_keys("☝🏼 Here's your personal link to the survey 🙂")
    browser.send_keys [:enter]
  end
end
