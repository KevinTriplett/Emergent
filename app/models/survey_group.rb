class SurveyGroup < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_questions, dependent: :destroy
  has_many :notes, dependent: :destroy

  def ordered_questions
    survey_questions.order(position: :asc)
  end

  def ordered_notes
    notes.order(position: :asc)
  end
end
