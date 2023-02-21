class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_invite
  belongs_to :survey_question
  has_secure_token

  delegate :user, :survey, to: :survey_invite
  delegate :question_type, :question, :has_scale?, :answer_type, to: :survey_question

  def votes
    vote_count || 0
  end

  def votes=(count)
    return vote_count if count.nil?
    count = [[0, count].max, survey_invite.votes_left].min
    self.vote_count = count
  end
end
