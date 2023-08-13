require 'kimurai'

class EmergeSpider < Kimurai::Base

  def name
    self.logger.progname
  end

  def get_and_clear_message
    msg = ::Spider.get_message(name)
    ::Spider.clear_message(name)
    return msg unless msg.blank?
    logger.fatal "MESSAGE WAS BLANK, EXITING"
    raise
  end

  def sign_in_and_send_request_to(method, url)
    ::Spider.clear_result(name)

    result = nil
    for i in 1..10 # limit the loop
      result = looped_sign_in
      break if result
      sleep 1
    end
    ::Spider.set_failure(name) unless result
    return false if ::Spider.failure?(name)

    for i in 1..10 # limit the loop
      result = looped_request_to(method, url)
      break if result
      sleep i
    end
    ::Spider.set_failure(name) unless result
    return ::Spider.success?(name)
  end

  def looped_request_to(method, url)
    request_to(method, url: url)
    logger.info "COMPLETED SUCCESSFULLY"
    true # don't loop
  rescue Net::ReadTimeout
    logger.info "TIMEOUT ERROR, TRYING AGAIN"
    Rails.logger.info "#{name}: TIMEOUT ERROR, TRYING AGAIN"
    false # try again
  rescue => error
    ::Spider.set_failure(name)
    logger.fatal "ERROR #{error.class}: #{error.message}"
    Rails.logger.info "#{name}: ERROR #{error.class}: #{error.message}"
    true # don't loop
  end

  def set_result(result)
    ::Spider.set_result(name, result)
  end

  def looped_sign_in
    sign_in
    true
  rescue Net::ReadTimeout
    logger.info "TIMEOUT ERROR, TRYING AGAIN"
    Rails.logger.info "TIMEOUT ERROR, TRYING AGAIN"
    false # continue loop
  rescue => error
    ::Spider.set_failure(name)
    logger.fatal "ERROR #{error.class}: #{error.message}"
    Rails.logger.info "ERROR #{error.class}: #{error.message}"
    true # don't loop
  end

  def sign_in
    return if response_has("body.communities-app") # return if already signed in
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
