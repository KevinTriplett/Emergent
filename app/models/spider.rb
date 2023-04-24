class Spider < ActiveRecord::Base
  def self.set_message(name, new_msg)
    spider = find_by_name(name) || create_spider(name)
    spider.update(message: new_msg)
  end

  def self.append_message(name, new_msg)
    spider = find_by_name(name) || create_spider(name)
    messages = spider.message.blank? ? [] : spider.message.split(",")
    messages.push new_msg
    spider.update(message: messages.join(","))
  end

  def self.message?(name)
    spider = find_by_name(name)
    !spider.message.blank?
  end

  def self.get_message(name)
    spider = find_by_name(name)
    message = spider.message
    spider.update(message: nil)
    message
  end

  def self.set_result(name, result)
    spider = find_by_name(name)
    spider.update(result: result)
  end

  def self.get_result(name)
    spider = find_by_name(name)
    result = spider.result
    spider.update(result: nil)
    result
  end

  def self.create_spider(name)
    create(name: name)
  end

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

  end

  def self.send_magic_links
    return unless message?("magic_link_spider")
    MagicLinkSpider.crawl!
    until get_result("magic_link_spider") == "success"
      sleep 1
    end
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