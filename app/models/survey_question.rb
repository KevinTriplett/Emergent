class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey_group
  has_many :survey_answers, dependent: :destroy
  has_one :note, dependent: :destroy

  delegate :survey, :survey_id, :survey_questions,
    :ordered_questions, to: :survey_group
  delegate :ordered_groups, to: :survey

  QUESTION_TYPES = [
    "Question",
    "Instructions",
    "New Page",
    "Note"
  ]
  QUESTION_TYPES.each do |_type|
    define_method("#{_type.downcase.gsub(/\s+/, "_")}?") { _type == question_type }
  end

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
  ANSWER_TYPES.each do |_type|
    define_method("#{_type.downcase.gsub(/\s+/, "_")}?") { _type == answer_type }
  end

  # ----------------------------------------------------------------------

  def group_position
    survey_group.position
  end

  def group_name
    survey_group.name
  end
  def group_name=(name)
    group = survey.survey_groups.where(name: name).first
    return unless group
    self.survey_group_id = group.id
    self.position = group.survey_questions.count
  end

  def update_from_note
    self.question = note.text
    self.group_name = note.group_name
    save
  end

  def update_note
    note ? note.update_from_survey_question : true
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
      state = STATES[:question_found] if sq.question? || sq.instructions?
      sq.new_page? && STATES[:question_found] == state
    end
  end

  def at_group_ending?
    state = STATES[:seeking]
    !ordered_questions.reverse.any? do |sq|
      break if sq.position <= position
      state = STATES[:question_found] if sq.question? || sq.instructions?
      sq.new_page? && STATES[:question_found] == state
    end
  end
end
  