class AddUrlToSurveyInvites < ActiveRecord::Migration[7.0]
  def change
    add_column :survey_invites, :url, :string
  end
end
