class RemoveGroupNameColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :survey_questions, :group_name, :string
  end
end
