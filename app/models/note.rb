class Note < ActiveRecord::Base
  belongs_to :survey_group
  belongs_to :survey_question, dependent: :destroy
  delegate :survey, :notes, to: :survey_group

  def group_name
    survey_group.name
  end

  def group_color
    survey_group.note_color
  end
  def group_color=(new_color)
    survey_group.update note_color: new_color
  end

  def group_name=(name)
    group = survey.survey_groups.where(name: name).first
    return unless group
    self.survey_group_id = group.id
    self.position = group.notes.count
  end

  def group_position
    survey_group.position
  end

  def ordered_groups
    survey_group.ordered_groups
  end

  def update_from_survey_question
    self.text = survey_question.question
    self.group_name = survey_question.group_name
    save
  end

  def update_survey_question
    survey_question.update_from_note
  end
end
