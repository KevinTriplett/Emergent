require 'kimurai'

class EmergeSpider < Kimurai::Base

  def name
    self.logger.progname
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

  def response_has(css)
    browser.current_response.css(css).length > 0
  end

  def wait_while(css)
    for i in 0..10
      return true unless response_has(css)
      EmergeSpider.logger.debug "#{name} WAITING WHILE #{css} ..."
      sleep 1
    end
    raise_error_if_response_has(css)
  end

  def wait_until(css)
    for i in 0..10
      return true if response_has(css)
      EmergeSpider.logger.debug "#{name} WAITING UNTIl #{css} ..."
      sleep 1
    end
    raise_error_unless_response_has(css)
  end
end
