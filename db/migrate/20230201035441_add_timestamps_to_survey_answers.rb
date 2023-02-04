class AddTimestampsToSurveyAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_answers, "created_at", :datetime, null: false
    add_column :survey_answers, "updated_at", :datetime, null: false
  end
end
