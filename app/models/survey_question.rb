class SurveyQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_answers

  QUESTION_TYPES = [
    "Question",
    "Instructions",
    "New Page",
    "Scale",
    "Branch"
  ]
  ANSWER_TYPES = [
    "Yes/No",
    "Multiple Choice",
    "Essay",
    "Rating",
    "Number",
    "NA"
  ]
end
  