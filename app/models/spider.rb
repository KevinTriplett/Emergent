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

  def self.get_message_and_clear(name)
    msg = get_message(name)
    clear_message(name)
    msg
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
      for i in 1..4 # limit the loop
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
      user.profile_url = "https://emergent-commons.mn.co/members/#{user.member_id}"
      user.chat_url = "https://emergent-commons.mn.co/chats/new?user_id=#{user.member_id}"
      user.approved = nil
      user.joined = true
      user.save
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end

  ########################

  def self.check_new_moderations
    Moderation.all.each do |moderation|
      next if moderation.replied?
      set_message("moderation_spider", moderation.id)
      ModerationSpider.crawl!
      for i in 1..60
        break if result?("moderation_spider")
        sleep 2
      end
      break if result?("moderation_spider")
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end

  ########################

  def self.get_new_members(qty)
    for i in 1..4 # limit the loop
      set_message("new_user_spider", qty.to_s)
      NewUserSpider.crawl!
      for i in 1..60
        break if result?("new_user_spider")
        sleep 2
      end
      break if success?("new_user_spider")
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end
  
  ########################

  def self.send_magic_links
    return unless message?("magic_link_spider")
    for i in 1..4 # limit the loop
      MagicLinkSpider.crawl!
      for i in 1..60
        break if result?("magic_link_spider")
        sleep 2
      end
      break if success?("magic_link_spider")
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  end

  ########################

  def self.send_survey_invite_messages
    SurveyInvite.where(state: SurveyInvite::STATUS[:created]).each do |invite|
      next if Rails.configuration.mn_surveyor_username == invite.user.email # cannot send messages to signin account!
      send_survey_invitation_message(invite)
    end

    SurveyInvite.where(state: SurveyInvite::STATUS[:finished]).each do |invite|
      next if Rails.configuration.mn_surveyor_username == invite.user.email # cannot send messages to signin account!
      send_survey_finished_message(invite)
    end
  end

  ########################

  def self.send_survey_invitation_message(invite)
    set_message("private_message_spider", invite.get_invite_message)
    PrivateMessageSpider.crawl!
    for i in 1..60
      break if result?("private_message_spider")
      sleep 2
    end
    invite.update_state(:invite_sent) if success?("private_message_spider")
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  rescue EOFError
  end

  ########################

  def self.send_survey_finished_message(invite)
    first_group = invite.survey.ordered_groups.first
    return unless "Contact Info" == first_group.name
    delivery_method_question = first_group.survey_questions.where(answer_type: "Multiple Choice").first
    return unless delivery_method_question
    delivery_method = invite.survey_answer_for(delivery_method_question.id)
    return unless delivery_method && !delivery_method.answer.blank?

    case delivery_method.answer
    when "Email"
      email_question = first_group.survey_questions.where(answer_type: "Email").first
      return unless email_question
      email = invite.survey_answer_for(email_question.id)
      return unless email && !email.answer.blank?
      UserMailer.with({
        email: email.answer,
        invite: invite,
        message: invite.get_finished_message,
        url: invite.url
      }).send_finished_survey_link.deliver_now
      invite.update_state(:finished_link_sent)
    when "Private Message"
      set_message("private_message_spider", invite.get_finished_message)
      PrivateMessageSpider.crawl!
      for i in 1..60
        break if result?("private_message_spider")
        sleep 2
      end
      invite.update_state(:finished_link_sent) if success?("private_message_spider")
    end
  rescue Selenium::WebDriver::Error::UnknownError
  rescue Net::ReadTimeout
  rescue EOFError
  end

  ########################

  def self.run_spiders
    approve_members
    get_new_members(20)
    send_magic_links
    send_survey_invite_messages
    check_new_moderations
  end
end