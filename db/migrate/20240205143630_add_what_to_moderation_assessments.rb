class AddWhatToModerationAssessments < ActiveRecord::Migration[7.0]
  def change
    add_column :moderation_assessments, :what, :text
  end
end
