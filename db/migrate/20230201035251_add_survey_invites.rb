class AddSurveyInvites < ActiveRecord::Migration[7.0]
  def change
    create_table :survey_invites do |t|
      t.references :survey
      t.references :user
      t.text :subject
      t.text :body
      t.datetime :sent_timestamp
      t.string :token
      t.index :token
      
      t.timestamps
    end
  end
end
