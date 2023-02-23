class SurveyGroup < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_questions

  def ordered_questions
    survey_questions.order(position: :asc)
  end
end
