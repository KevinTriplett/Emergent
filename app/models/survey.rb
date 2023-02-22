class Survey < ActiveRecord::Base
  has_many :survey_questions
  has_many :survey_invites
  has_many :users, through: :survey_invites
  has_many :notes

  def ordered_questions
    survey_questions.order(position: :asc)
  end

  def last_note_category
    default_category = "Category Name"
    return default_category if notes.blank?
    notes.order(created_at: :asc).last.category || default_category
  end
end
