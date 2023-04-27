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

  def self.approve_members
    User.where(approved: true).each do |user|
      for i in 1..10 # limit the loop
        data = [user.first_name, user.last_name].join('|')
        set_message("approve_user_spider", data)
        ApproveUserSpider.crawl!
        for i in 1..60
          break if result?("approve_user_spider")
          sleep 2
        end
        break if result?("approve_user_spider")
      end
      return if !result?("approve_user_spider") || failure?("approve_user_spider")
      user.member_id = get_result("approve_user_spider").to_i
      user.approved = nil
      user.save
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end

  def self.get_new_members(qty)
    for i in 1..10 # limit the loop
      set_message("new_user_spider", qty.to_s)
      NewUserSpider.crawl!
      for i in 1..60
        break if result?("new_user_spider")
        sleep 1
      end
      break if success?("new_user_spider")
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end
  
  def self.send_magic_links
    return unless message?("magic_link_spider")
    MagicLinkSpider.crawl!
    for i in 1..60
      break if result?("magic_link_spider")
      sleep 1
    end
    break if success?("magic_link_spider")
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end

  def self.send_survey_invite_messages
    SurveyInvite.where(state: SurveyInvite::STATUS[:created]).each do |invite|
      next if Rails.configuration.mn_username == invite.user.email # cannot send messages to signin account!
      set_message("private_message_spider", invite.get_invite_message)
      PrivateMessageSpider.crawl!
      for i in 1..60
        break if result?("private_message_spider")
        sleep 1
      end
      next unless success?("private_message_spider")
      invite.update_state(:invite_sent) if success?("private_message_spider")
    end

    SurveyInvite.where(state: SurveyInvite::STATUS[:finished]).each do |invite|
      next if Rails.configuration.mn_username == invite.user.email # cannot send messages to signin account!

      first_group = invite.survey.ordered_groups.first
      next unless "Contact Info" == first_group.name
      delivery_method_question = first_group.survey_questions.where(answer_type: "Multiple Choice").first
      next unless delivery_method_question
      delivery_method = invite.survey_answer_for(delivery_method_question.id)
      next unless delivery_method && delivery_method.answer
  
      case delivery_method.answer
      when "Email"
        email_question = first_group.survey_questions.where(answer_type: "Email").first
        next unless email_question
        email = invite.survey_answer_for(email_question.id)
        next unless email && !email.answer.blank?
        UserMailer.with({
          email: email.answer,
          invite: self,
          message: invite.get_finished_message,
          url: url
        }).send_finished_survey_link.deliver_now
      when "Private Message"
        set_message("private_message_spider", invite.get_finished_message)
        PrivateMessageSpider.crawl!
        for i in 1..60
          break if result?("private_message_spider")
          sleep 1
        end
        next if success?("private_message_spider")
      end
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end

  def self.run_spiders
    approve_members
    get_new_members(50)
    send_magic_links
    send_survey_invite_messages
  end
end