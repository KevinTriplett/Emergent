class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey_group
  has_many :survey_answers

  delegate :survey, :survey_id, :ordered_questions, to: :survey_group

  def group_position
    survey_group.position
  end

  def at_beginning?
    return false if group_position > 0
    at_group_beginning?
  end

  def at_ending?
    return false if group_position < survey.survey_groups.count-1
    at_group_ending?
  end

  def at_group_beginning?
    !ordered_questions.any? do |sq|
      break if sq.position >= position
      sq.question_type == "New Page"
    end
  end

  def at_group_ending?
    !ordered_questions.reverse.any? do |sq|
      break if sq.position <= position
      sq.question_type == "New Page"
    end
  end

  QUESTION_TYPES = [
    "Question",
    "Instructions",
    "New Page",
    "Group Name",
    "Branch"
  ]
  ANSWER_TYPES = [
    "Yes/No",
    "Multiple Choice",
    "Essay",
    "Rating",
    "Range",
    "Number",
    "Vote",
    "NA"
  ]
end
  