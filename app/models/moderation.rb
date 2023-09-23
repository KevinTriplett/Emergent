class Moderation < ActiveRecord::Base
  has_and_belongs_to_many :violations
  belongs_to :user, optional: true
  belongs_to :moderator, class_name: "User"
  has_secure_token

  def user_name
    user ? user.name : ""
  end
  def moderator_name
    moderator ? moderator.name : ""
  end
end