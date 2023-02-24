class Note < ActiveRecord::Base
  belongs_to :survey_group
  delegate :survey, :notes, to: :survey_group

  def group_name
    survey_group.name
  end

  def group_name=(name)
    group = survey.groups.where(name: name).first
    survey_group_id = group.id
  end

  def ordered_groups
    survey_group.ordered_groups
  end
end
