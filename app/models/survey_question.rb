class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey_group
  has_many :survey_answers, dependent: :destroy
  has_one :note, dependent: :destroy

  delegate :survey, :survey_id, :survey_questions,
    :ordered_questions, to: :survey_group

  QUESTION_TYPES = [
    "Question",
    "Instructions",
    "New Page",
    "Notes"
  ]
  ANSWER_TYPES = [
    "Yes/No",
    "Multiple Choice",
    "Essay",
    "Rating",
    "Range",
    "Number",
    "Vote",
    "Email",
    "NA"
  ]

  def group_position
    survey_group.position
  end

  def group_name
    survey_group.name
  end
  def group_name=(name)
    group = survey.survey_groups.where(name: name).first
    self.survey_group_id = group.id if group
  end

  def update_from_note
    self.question = note.text
    self.group_name = note.group_name
    self.save
  end

  def at_beginning?
    return false if group_position > 0
    at_group_beginning?
  end

  def at_ending?
    return false if group_position < survey.survey_groups.count-1
    at_group_ending?
  end

  # for use in testing for beginning and ending
  STATES = {
    seeking: 10,
    question_found: 20
  }
  
  def at_group_beginning?
    state = STATES[:seeking]
    !ordered_questions.any? do |sq|
      break if sq.position >= position
      state = STATES[:question_found] if "New Page" != sq.question_type
      "New Page" == sq.question_type && STATES[:question_found] == state
    end
  end

  def at_group_ending?
    state = STATES[:seeking]
    !ordered_questions.reverse.any? do |sq|
      break if sq.position <= position
      state = STATES[:question_found] if "New Page" != sq.question_type
      "New Page" == sq.question_type && STATES[:question_found] == state
    end
  end
end
  