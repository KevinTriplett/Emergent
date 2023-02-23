class AddSurveyGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :survey_groups do |t|
      t.references :survey
      t.string :name
      t.string :description
      t.integer :votes_max
      t.integer :position

      t.timestamps
    end

    remove_column :surveys, :vote_max, :integer
    add_column    :survey_questions, :survey_group_id, :integer
    add_index     :survey_questions, :survey_group_id
    remove_index  :survey_questions, :survey_id
    remove_column :survey_questions, :survey_id, :integer
  end
end
