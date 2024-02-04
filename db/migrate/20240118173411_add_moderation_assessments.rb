class AddModerationAssessments < ActiveRecord::Migration[7.0]
  def change
    create_table :moderation_assessments do |t|
      t.string :token
      t.integer :state
      t.string :url
      t.string :original_text
      t.string :assessment
      t.belongs_to :user, null: true
      t.string :thread_id
      t.string :message_id
      t.string :run_id
      t.string :reply
      t.timestamps
    end
  end
end
