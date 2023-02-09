class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_invite
  belongs_to :survey_question

  delegate :user, :survey, to: :survey_invite
  delegate :question, :has_scale?, :answer_type, to: :survey_question
end
