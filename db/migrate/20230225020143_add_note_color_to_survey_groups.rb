class AddNoteColorToSurveyGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_groups, :note_color, :string
  end
end
