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
end