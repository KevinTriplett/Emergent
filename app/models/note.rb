class Note < ActiveRecord::Base
  belongs_to :survey_group
  belongs_to :survey_question, dependent: :destroy
  delegate :survey, :notes, to: :survey_group
  delegate :survey_answer, to: :survey_question

  def group_name
    survey_group.name
  end

  def group_name=(name)
    group = survey.survey_groups.where(name: name).first
    self.survey_group_id = group.id if group
  end

  def ordered_groups
    survey_group.ordered_groups
  end

  def update_survey_question
    survey_question.update_from_note
  end
end
