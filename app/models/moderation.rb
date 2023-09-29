class Moderation < ActiveRecord::Base
  has_and_belongs_to_many :violations
  belongs_to :user, optional: true
  belongs_to :moderator, class_name: "User"
  has_secure_token

  STATUS = {
    created: 0,
    recorded: 10,
    replied: 20,
    resolved: 30
  }
  STATUS.each do |key, val|
    define_method("is_#{key}?") { (state || 0) == val }
    define_method("#{key}?") { (state || 0) >= val }
  end
  
  def get_state
    Moderation::STATUS.key(state)
  end

  # ----------------------------------------------------------------------

  def user_name
    user ? user.name : ""
  end
  def moderator_name
    moderator ? moderator.name : ""
  end

  def update_state(key, write_to_database=true)
    return false unless STATUS[key]
    return true if state && state >= STATUS[key]
    self.state = STATUS[key]
    self.state_timestamp = Time.now
    return true unless write_to_database
    save
  end
end