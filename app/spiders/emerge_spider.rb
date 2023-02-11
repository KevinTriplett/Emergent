require 'kimurai'

class EmergeSpider < Kimurai::Base

  def name
    self.logger.progname
  end

  def get_message
    msg = ::Spider.get_message(name)
    return msg if msg
    EmergeSpider.logger.failure "#{name} MESSAGE WAS NIL, EXITING"
    raise
  end

  def set_result(result)
    ::Spider.set_result(name, result)
  end

  def sign_in(response, url:, data: {})
    return if response_has("body.communities-app")

    EmergeSpider.logger.info "#{name} SIGNING IN"
    wait_until("body.auth-sign_in")
    browser.fill_in "Email", with: Rails.configuration.mn_username
    browser.fill_in "Password", with: Rails.configuration.mn_password
    browser.click_link "Sign In"
    wait_while(".pace-running")
    wait_until("body.communities-app")
    EmergeSpider.logger.info "#{name} SIGNIN SUCCESSFUL"
  end

  def raise_error_unless_response_has(css)
    raise "ERROR: #{name} could not find css #{css}" unless response_has(css)
  end

  def raise_error_if_response_has(css)
    raise "ERROR: #{name} could not find css #{css}" if response_has(css)
  end

  def response_has(css, text=nil)
    browser.current_response.css(css).length > 0 && (!text || browser.current_response.css(css).text == text)
  end

  def wait_while(css, text=nil)
    for i in 0..10
      return true unless response_has(css, text)
      EmergeSpider.logger.debug "#{name} WAITING WHILE #{css} ..."
      sleep 1
    end
    raise_error_if_response_has(css)
  end

  def wait_until(css, text=nil)
    for i in 0..10
      return true if response_has(css, text)
      EmergeSpider.logger.debug "#{name} WAITING UNTIl #{css} ..."
      sleep 1
    end
    raise_error_unless_response_has(css)
  end
end
