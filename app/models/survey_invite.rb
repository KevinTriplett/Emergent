class SurveyInvite < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  has_secure_token

  def ensure_token
    update(token: SurveyInvite.generate_unique_secure_token) if token.nil?
    token
  end

  def self.queued
    where(sent_timestamp: nil)
  end
end
