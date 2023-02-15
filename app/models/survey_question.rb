class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_answers

  def first_question?
    position == 0
  end
  def last_question?
    position == survey.survey_questions.count-1
  end

  QUESTION_TYPES = [
    "Question",
    "Instructions",
    "New Page",
    "Branch"
  ]
  ANSWER_TYPES = [
    "Yes/No",
    "Multiple Choice",
    "Essay",
    "Rating",
    "Scale",
    "Number",
    "NA"
  ]
end
  