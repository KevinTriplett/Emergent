class SurveyInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many :survey_answers
  has_many :survey_questions, through: :survey
  has_secure_token

  delegate :ordered_questions, to: :survey

  def update_state(key, write_to_database=true)
    return true if state && state >= STATUS[key]
    self.state = STATUS[key]
    self.state_timestamp = Time.now
    return true unless write_to_database
    save
  end

  def votes_total
    votes = survey_answers.select do |answer| 
      answer.update(vote_count: 0) unless answer.vote_count
      "Vote" == answer.survey_question.answer_type
    end.collect(&:vote_count)
    votes.sum(0)
  end

  def votes_left
    (survey.vote_max || 0) - votes_total
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
