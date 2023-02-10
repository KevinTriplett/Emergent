class Survey < ActiveRecord::Base
  has_many :survey_questions
  has_many :survey_invites
  has_many :users, through: :survey_invites
end