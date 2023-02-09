class ChangeSurveys < ActiveRecord::Migration[7.0]
  def change
    add_column    :survey_questions, :group_name, :string

    add_column    :survey_invites, :state, :integer
    add_index     :survey_invites, :state
    add_column    :survey_invites, :state_timestamp, :datetime
    remove_column :survey_invites, :sent_timestamp, :datetime

    add_column    :survey_answers, :survey_invite_id, :integer
    add_index     :survey_answers, :survey_invite_id
    remove_column :survey_answers, :user_id, :integer
  end
end
