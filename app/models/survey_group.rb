class SurveyGroup < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_questions
  has_many :notes

  delegate :ordered_groups, to: :survey

  def ordered_questions
    survey_questions.order(position: :asc)
  end
end
