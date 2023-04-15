require 'kimurai'

class EmergeSpider < Kimurai::Base

  def name
    self.logger.progname
  end

  def get_message
    msg = ::Spider.get_message(name)
    return msg if msg
    logger.fatal "MESSAGE WAS NIL, EXITING"
    raise
  end

  def send_request_to(method, url)
    for i in 1..10 # limit the loop
      break if looped_request_to(method, url)
    end
  end

  def looped_request_to(method, url)
    request_to(method, url: url)
    logger.info "COMPLETED SUCCESSFULLY"
    set_result("success")
    true # don't loop
  rescue Net::ReadTimeout
    logger.info "TIMEOUT ERROR, TRYING AGAIN"
    false # continue loop
  rescue => error
    set_result("failure")
    logger.fatal "ERROR #{error.class}: #{error.message}"
    true # don't loop
  end

  def set_result(result)
    ::Spider.set_result(name, result)
  end

  def sign_in
    return if response_has("body.communities-app")

    logger.info "SIGNING IN"
    wait_until("body.auth-sign_in")
    browser.fill_in "Email", with: Rails.configuration.mn_username
    browser.fill_in "Password", with: Rails.configuration.mn_password
    browser.click_link "Sign In"
    wait_while(".pace-running")
    wait_until("body.communities-app")
    logger.info "SIGNIN SUCCESSFUL"
  end

  def raise_error_unless_response_has(css)
    raise "ERROR: could not find css #{css}" unless response_has(css)
  end

  def raise_error_if_response_has(css)
    raise "ERROR: could not find css #{css}" if response_has(css)
  end

  def response_has(css, text=nil)
    browser.current_response.css(css).length > 0 && (!text || browser.current_response.css(css).text == text)
  end

  def wait_while(css, text=nil)
    for i in 0..10
      return true unless response_has(css, text)
      logger.debug "WAITING WHILE #{css} ..."
      sleep 1
    end
    raise_error_if_response_has(css)
  end

  def wait_until(css, text=nil)
    for i in 0..10
      return true if response_has(css, text)
      logger.debug "WAITING UNTIL #{css} ..."
      sleep 1
    end
    raise_error_unless_response_has(css)
  end
end
