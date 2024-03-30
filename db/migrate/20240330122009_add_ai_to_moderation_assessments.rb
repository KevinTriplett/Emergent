class AddAiToModerationAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :moderation_assessments, :ai_model_name, :string
  end
end
