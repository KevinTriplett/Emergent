class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_invite
  belongs_to :survey_question
  has_secure_token

  delegate :user, :survey, to: :survey_invite
  delegate :question_type, :question, :has_scale?, :answer_type, to: :survey_question
end
