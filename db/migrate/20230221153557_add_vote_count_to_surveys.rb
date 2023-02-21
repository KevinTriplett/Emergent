class AddVoteCountToSurveys < ActiveRecord::Migration[7.0]
  def change
    add_column :surveys, :vote_max, :integer
    add_column :survey_answers, :vote_count, :integer
  end
end
