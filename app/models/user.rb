class User < ActiveRecord::Base
  belongs_to :greeter, class_name: "User", optional: true
  belongs_to :shadow_greeter, class_name: "User", optional: true
  has_many :users, through: :greeter
  has_many :survey_invites, dependent: :destroy
  has_many :surveys, through: :survey_invites
  has_secure_token

  def revoke_tokens
    # update(token: nil) # nil token can break many views
    update(session_token: nil)
  end
  def generate_tokens
    update(token: User.generate_unique_secure_token) if token.nil?
    update(session_token: SecureRandom.urlsafe_base64) if session_token.nil?
  end
  def regenerate_tokens
    revoke_tokens
    generate_tokens
  end

  def lock
    update locked: true
  end
  def unlock
    update locked: false
  end

  # NB: role order is zero-based
  def add_role(role, role_hash)
    return true if has_role?(role)
    if role_hash[:order].present?
      # NB: this will take time with large number of users
      users_with_role = User.all.select {|u| id && u.has_role?(role)}
      role_hash[:order] = users_with_role.length
    end
    update_role(role, role_hash)
  end

  def remove_role(role)
    return true unless has_role?(role)
    user_role_order = delete_role(role)[:order]
    return unless user_role_order.present?

    # NB: this will take time with large number of users
    User.all.each do |u|
      role_hash = u.get_role(role)
      next unless role_hash && role_hash[:order] > user_role_order
      role_hash[:order] -= 1
      u.update_role(role, role_hash)
    end
  end

  def get_role(role)
    get_roles[role]
  end

  def list_roles
    get_roles.keys
  end

  def has_role?(role)
    !get_role(role).nil?
  end

  def notes_abbreviated
    # TODO use default arg for number
    notes ? "#{notes[0..15]}#{notes_ellipsis(16)}" : nil
  end

  def notes_ellipsis(len)
    notes.length > len ? "..." : nil
  end

  # NB: role order is zero-based
  def add_role(role, role_hash)
    return true if has_role?(role)
    if role_hash[:order].present?
      # NB: this will take time with large number of users
      users_with_role = User.all.select {|u| id && u.has_role?(role)}
      role_hash[:order] = users_with_role.length
    end
    update_role(role, role_hash)
  end

  def remove_role(role)
    return true unless has_role?(role)
    user_role_order = delete_role(role)[:order]
    return unless user_role_order.present?

    # NB: this will take time with large number of users
    User.all.each do |u|
      role_hash = u.get_role(role)
      next unless role_hash && role_hash[:order] > user_role_order
      role_hash[:order] -= 1
      u.update_role(role, role_hash)
    end
  end

  def get_role(role)
    get_roles[role]
  end

  def list_roles
    get_roles.keys
  end

  def has_role?(role)
    !get_role(role).nil?
  end

  def get_status_options
    {
      "Pending": [
        "Request Declined"
      ],
      "Request Declined": [
        "Pending"
      ],
      "Scheduling Zoom": [
        "Zoom Scheduled",
        "Zoom Declined (completed)",
        "Chat Done (completed)",
        "No Response (completed)"
      ],
      "Zoom Scheduled": [
        "Zoom Done (completed)",
        "Scheduling Zoom"
      ],
      "Zoom Done (completed)":[
        "Scheduling Zoom"
      ],
      "Zoom Declined (completed)":[
        "Scheduling Zoom"
      ],
      "Chat Done (completed)":[
        "Scheduling Zoom"
      ],
      "No Response (completed)":[
        "Scheduling Zoom"
      ]
    }[status.to_sym].insert(0, status)
  # handle older greetings:
  rescue NoMethodError
    return [
      "Pending",
      "Rejected",
      "Joined!",
      "Clarifying email sent",
      "1st email Sent",
      "2nd email Sent",
      "Emailing",
      "No Response",
      "Rescheduling",
      "Follow Up",
      "Will Call",
      "Greet Scheduled",
      "Declined",
      "Welcomed",
      "Posted Intro",
      "Completed",
      "Scheduling Zoom",
      "Zoom Scheduled",
      "Zoom Declined (completed)",
      "Chat Done (completed)",
      "No Response (completed)",
      "Zoom Done (completed)"
    ]
  end

  def self.import_users
    file = File.open "tmp/import.tsv"
    data = file.readlines.map(&:chomp)
    file.close

    # check first row for correct file format
    headers = data.shift
    correct_headers = %w{first_name last_name email member_id join_date join_timestamp location time_zone country}.join("\t")
    unless headers == correct_headers
      puts "header row = #{headers}" # first line is headers
      puts "should be  = #{correct_headers}"
      return
    end

    data.each do |line|
      first_name, last_name, email, member_id, x, join_timestamp, location, time_zone, country = line.split("\t")
      location = location.gsub(/\"/, "") if location
      name = "#{first_name} #{last_name}"
      profile_url = "https://emergent-commons.mn.co/members/#{member_id}"
      chat_url = "https://emergent-commons.mn.co/chats/new?user_id=#{member_id}"

      user = email.present? ? find_by_email(email) : find_by_name(name)
      if user
        puts "updating #{name}"
        user = find_by_email(email)
        user.update(name: name)
        user.update(first_name: first_name)
        user.update(last_name: last_name)
        user.update(email: email.downcase)
        user.update(member_id: member_id)
        user.update(profile_url: profile_url)
        user.update(chat_url: chat_url)
        user.update(join_timestamp: join_timestamp)
        user.update(location: location)
        user.update(country: country)
        user.update(time_zone: time_zone)
      else
        puts "creating #{name}"
        create({
          name: name,
          first_name: first_name,
          last_name: last_name,
          email: email.downcase,
          member_id: member_id,
          profile_url: profile_url,
          chat_url: chat_url,
          status: "existing",
          join_timestamp: join_timestamp,
          location: location,
          country: country,
          time_zone: time_zone
        })
      end
    end
  end

  protected

  def get_roles
    roles ? Marshal.load(roles) : {}
  end

  def update_role(role, role_hash)
    new_roles = get_roles
    new_roles[role] = role_hash
    update(roles: Marshal.dump(new_roles))
    new_roles[role]
  end

  def delete_role(role)
    new_roles = get_roles
    old_role = new_roles.delete(role)
    update(roles: Marshal.dump(new_roles))
    old_role
  end
end