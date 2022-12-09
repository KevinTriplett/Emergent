class Spider < ActiveRecord::Base
  def self.set_message(name, message)
    spider = find_by_name(name)
    spider.update(message: message)
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
end