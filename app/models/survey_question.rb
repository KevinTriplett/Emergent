class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_answers
  has_many :users, through: :survey_answers
end
  