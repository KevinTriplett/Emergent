class SurveyInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_many :survey_answers
  has_many :survey_questions, through: :survey
  has_secure_token

  def generate_token
    update(token: SurveyInvite.generate_unique_secure_token) if token.nil?
    token
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
