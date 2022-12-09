require 'kimurai'

class EmergeSpider < Kimurai::Base

  def name
    self.logger.progname
  end

  def sign_in(response, url:, data: {})
    wait_until("body.auth-sign_in")
    EmergeSpider.logger.debug "#{name} SIGNING IN"
    browser.fill_in "Email", with: Rails.configuration.mn_username
    sleep 1
    browser.fill_in "Password", with: Rails.configuration.mn_password
    browser.click_link "Sign In"
    sleep 1
    wait_while(".pace-running")
    EmergeSpider.logger.debug "#{name} SIGIN SUCCESSFUL"
  end

  def report_failure_unless_response_has(css)
    return if response_has(css)
    EmergeSpider.logger.debug "Expected to find #{css}"
    raise
  end

  def response_has(css)
    browser.current_response.css(css).length > 0
  end

  def wait_while(css)
    i = 10
    sleep 1
    while response_has(css) || i < 0
      EmergeSpider.logger.debug "#{name} WAITING WHILE #{css} ..."
      sleep 1
      i -= 1
    end
    EmergeSpider.logger.debug "#{name} NEVER WENT AWAY!" if response_has(css)
  end

  def wait_until(css)
    i = 10
    sleep 1
    until response_has(css) || i < 0
      EmergeSpider.logger.debug "#{name} WAITING UNTIl #{css} ..."
      sleep 1
      i -= 1
    end
    EmergeSpider.logger.debug "#{name} COULD NOT FIND IT!" unless response_has(css)
  end
end
