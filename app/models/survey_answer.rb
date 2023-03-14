class SurveyAnswer < ActiveRecord::Base
  belongs_to :survey_invite
  belongs_to :survey_question
  has_secure_token

  delegate :user, :survey, to: :survey_invite
  delegate :question_type, :question, :has_scale?, :answer_type,
    :survey_group, :survey_group_id, :group_position, to: :survey_question

  def votes
    vote_count || 0
  end

  def votes=(count)
    count = [[0, count || 0].max, (votes + votes_left)].min
    self.vote_count = count
  end

  def votes_left
    votes_max - votes_total
  end

  def votes_max
    survey_group.votes_max || 0
  end

  def votes_total
    survey_invite.votes_total(survey_group_id) || 0
  end

  def vote_thirds
    one_third = (votes_max / 3).to_i
    case votes
    when 0
      0
    when 1..one_third
      1
    when one_third+1..one_third*2
      2
    else
      3
    end
  end
end
