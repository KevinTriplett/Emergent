class Spider < ActiveRecord::Base
  def self.get_spider(name)
    uncached do
      find_by_name(name) || create(name: name)
    end
  end

  def self.set_message(name, new_msg)
    get_spider(name).update(message: new_msg)
  end

  def self.append_message(name, new_msg)
    spider = get_spider(name)
    messages = spider.message.blank? ? [] : spider.message.split(",")
    messages.push new_msg
    spider.update(message: messages.join(","))
  end

  def self.message?(name)
    !get_spider(name).message.nil?
  end

  def self.clear_message(name)
    get_spider(name).update(message: nil)
  end

  def self.get_message(name)
    get_spider(name).message
  end

  def self.set_result(name, result)
    get_spider(name).update(result: result)
  end

  def self.set_success(name)
    set_result(name, "success")
  end

  def self.set_failure(name)
    set_result(name, "failure")
  end

  def self.success?(name)
    get_spider(name).result == "success"
  end

  def self.failure?(name)
    get_spider(name).result == "failure"
  end

  def self.result?(name)
    !get_spider(name).result.nil?
  end

  def self.clear_result(name)
    get_spider(name).update(result: nil)
  end

  def self.get_result(name)
    get_spider(name).result
  end

  ################
  ## rake tasks
  ################

  def self.get_new_members(qty)
    success = nil
    for i in 1..10 # limit the loop
      set_message("new_user_spider", qty.to_s)
      NewUserSpider.crawl!
      until success = (get_result("new_user_spider") == "success")
        sleep i # use the loop index to extend the wait gradually
      end
      break if success
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end

  def self.send_magic_links
    return unless message?("magic_link_spider")
    MagicLinkSpider.crawl!
    until get_result("magic_link_spider") == "success"
      sleep 1
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end

  def self.send_survey_invite_messages
    SurveyInvite.send_messages
  end

  def self.run_spiders
    get_new_members(50)
    send_magic_links
    send_survey_invite_messages
  end
end