class SurveyInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many :survey_answers
  has_many :survey_questions, through: :survey
  has_secure_token

  delegate :ordered_questions, to: :survey

  def update_state(key, write_to_database=true)
    return true unless state && state < STATUS[key]
    self.state = STATUS[key]
    self.state_timestamp = Time.now
    return true unless write_to_database
    save
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
