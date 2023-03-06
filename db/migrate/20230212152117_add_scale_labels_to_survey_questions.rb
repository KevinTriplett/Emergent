class AddScaleLabelsToSurveyQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_questions, :scale_label_left, :string
    add_column :survey_questions, :scale_label_right, :string
  end
end
