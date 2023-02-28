class LinkNotesToSurveyQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :notes, :survey_question_id, :integer
    add_index :notes, :survey_question_id
  end
end
