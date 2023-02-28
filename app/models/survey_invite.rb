class SurveyInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many :survey_answers
  has_secure_token

  delegate :survey_groups, to: :survey

  def update_state(key, write_to_database=true)
    return true if state && state >= STATUS[key]
    self.state = STATUS[key]
    self.state_timestamp = Time.now
    return true unless write_to_database
    save
  end

  def get_survey_answer(survey_question_id)
    survey_answers.where(survey_question_id: survey_question_id).first
  end

  def votes_total(group_id)
    group_answers = survey_answers.select { |sa| sa.survey_group_id == group_id }
    group_answers.select { |sa| sa.survey_question.vote? }.collect(&:votes).sum(0)
  end

  def self.queued
    where(state: STATUS[:created])
  end

  STATUS = {
    created: 0,
    sent: 10,
    opened: 20,
    started: 30,
    finished: 40
  }

  STATUS.each do |key, val|
    define_method("is_#{key}") { (state || 0) == val }
    define_method("#{key}?") { (state || 0) >= val }
  end
end
