class Survey < ActiveRecord::Base
  has_many :survey_questions
end
