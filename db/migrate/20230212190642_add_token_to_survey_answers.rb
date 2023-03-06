class AddTokenToSurveyAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_answers, :token, :string
  end
end
