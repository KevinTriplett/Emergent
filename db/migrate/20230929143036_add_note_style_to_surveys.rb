class AddNoteStyleToSurveys < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_groups, :note_style, :integer
  end
end
