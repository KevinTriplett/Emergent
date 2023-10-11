class SurveyGroup < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_questions, dependent: :destroy
  has_many :notes, dependent: :destroy


  NOTE_STYLE = [
    [:stickies, 10],
    [:voted, 20],
    [:ranked, 30]
  ]
  def get_note_style
    return note_style && NOTE_STYLE.select {|nsa| nsa[1] == note_style}.first[0]
  end

  def ordered_questions
    survey_questions.order(position: :asc)
  end

  def ordered_notes
    notes.order(position: :asc)
  end
end
