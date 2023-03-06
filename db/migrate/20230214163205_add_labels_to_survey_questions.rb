class AddLabelsToSurveyQuestions < ActiveRecord::Migration[7.0]
  def change
    remove_column :survey_questions, :scale_label_left, :string
    remove_column :survey_questions, :scale_label_right, :string
    add_column :survey_questions, :answer_labels, :string
    add_column :survey_questions, :scale_labels, :string
    add_column :survey_questions, :scale_question, :string
  end
end
