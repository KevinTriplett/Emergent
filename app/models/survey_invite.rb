
class SurveyInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many :survey_answers
  has_secure_token

  delegate :survey_groups, to: :survey

  STATUS = {
    created: 0,
    invite_sent: 10,
    opened: 20,
    started: 30,
    finished: 40,
    finished_link_sent: 50
  }
  STATUS.each do |key, val|
    define_method("is_#{key}") { (state || 0) == val }
    define_method("#{key}?") { (state || 0) >= val }
  end

  # ----------------------------------------------------------------------

  def survey_name
    survey.name
  end

  def update_state(key, write_to_database=true)
    return false unless STATUS[key]
    return true if state && state >= STATUS[key]
    self.state = STATUS[key]
    self.state_timestamp = Time.now
    return true unless write_to_database
    save
  end

  def survey_answer_for(sq_id)
    survey_answers.where(survey_question_id: sq_id).first
  end

  def votes_total(group_id)
    group_answers = survey_answers.select { |sa| sa.survey_group_id == group_id }
    group_answers.select { |sa| sa.survey_question.vote? }.collect(&:votes).sum(0)
  end

  # ----------------------------------------------------------------------

  def send_survey_invite_link
    # (do not use without member consent)
    # UserMailer.with({
    #   email: user.email,
    #   invite: self,
    #   subject: subject,
    #   body: body,
    #   url: url
    # }).send_survey_invite_link.deliver_now
    return true if Rails.configuration.mn_username == user.email # cannot send messages to signin account!
    puts "sending invite to #{user.name}"
    Spider.set_message("private_message_spider", get_invite_message)
    PrivateMessageSpider.crawl!
    until result = Spider.get_result("private_message_spider")
      sleep 1
    end
    puts "got result = #{result}"
    "success" == result
  rescue => error
    puts "#{error.class}: #{error.message}"
    false
  end

  def send_finished_survey_link
    # send email or PM depending on answer in survey
    # survey is created with an initial group / questions for this purpose
    first_group = survey.ordered_groups.first
    return true unless "Contact Info" == first_group.name

    delivery_method_question = first_group.survey_questions.where(answer_type: "Multiple Choice").first
    return true unless delivery_method_question

    delivery_method = survey_answer_for(delivery_method_question.id)
    return true unless delivery_method && delivery_method.answer

    case delivery_method.answer
    when "Email"
      email_question = first_group.survey_questions.where(answer_type: "Email").first
      return true unless email_question
      email = survey_answer_for(email_question.id)
      return true unless email && email.answer
      UserMailer.with({
        email: email.answer,
        invite: self,
        message: get_finished_message,
        url: url
      }).send_finished_survey_link.deliver_now
      return true
    when "Private Message"
      Spider.set_message("private_message_spider", get_finished_message)
      PrivateMessageSpider.crawl!
      until result = Spider.get_result("private_message_spider")
        sleep 1
      end
      "success" == result
    end
  rescue
    false
  end

  def get_invite_message
    [
      user.id.to_s,
      subject,
      body,
      "Here's your personal link to your completed survey:"
      url
    ].join("|")
    # this fails with postgresql error: PG::CharacterNotInRepertoire: ERROR:  invalid byte sequence for encoding "UTF8": 0xcf 0x3a
    # Marshal.dump({
    #   user_id: user.id,
    #   subject: subject,
    #   body: body,
    #   lines: [
    #     "Here's your personal link to the survey:"
    #   ],
    #   url: url
    # }).encode('UTF-8')
  end

  def get_finished_message
    [
      user.id.to_s,
      "Emergent Commons - your completed survey link",
      "Thank you again for completing the survey!",
      "Here's your personal link to your completed survey:"
      url
    ].join("|")
    # this fails with postgresql error: PG::CharacterNotInRepertoire: ERROR:  invalid byte sequence for encoding "UTF8": 0xcf 0x3a
    # Marshal.dump({
    #   user_id: user.id,
    #   subject: "Emergent Commons - your completed survey link",
    #   body: "Thank you again for completing the survey!",
    #   lines: [
    #     "Here's your personal link to your completed survey:"
    #   ],
    #   url: url
    # })
  end

  # ----------------------------------------------------------------------

  def self.send_messages
    all.each do |invite|
      if invite.created?
        invite.update_state(:invite_sent) if invite.send_survey_invite_link
      elsif invite.finished?
        invite.update_state(:finished_link_sent) if invite.send_finished_survey_link
      end
    end
  end

end
