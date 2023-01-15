class User < ActiveRecord::Base
  belongs_to :greeter, class_name: "User", optional: true
  belongs_to :shadow_greeter, class_name: "User", optional: true
  has_many :users, through: :greeter
  has_secure_token

  def ensure_token
    update(token: User.generate_unique_secure_token) if token.nil?
  end

  def generate_session_token
    # do not generate a new session_token bc that would break all other session_tokens
    update(session_token: SecureRandom.urlsafe_base64) unless session_token
    session_token
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

  def get_status_options
    {
      "Pending": [
        "Joined!",
        "Clarifying email sent"
      ],
      "Clarifying email sent": [
        "Joined!",
        "Rejected"
      ],
      "Joined!": [
        "1st welcome email sent"
      ],
      "1st welcome email sent": [
        "Scheduling zoom",
        "Zoom scheduled",
        "Zoom maybe later",
        "Zoom declined (completed)",
        "Chat done (completed)",
        "No response (completed)"
      ],
      "Zoom maybe later": [
        "Scheduling zoom",
        "Zoom scheduled",
        "Zoom declined (completed)",
        "Chat done (completed)"
      ],
      "Scheduling zoom": [
        "Zoom scheduled",
        "Zoom declined (completed)",
        "Chat done (completed)",
        "No response (completed)"
      ],
      "Zoom scheduled": [
        "Zoom done (completed)",
        "Zoom declined (completed)",
        "Chat done (completed)",
        "No response (completed)"
      ],
      "2nd welcome email sent": [
        "Scheduling zoom",
        "Zoom scheduled",
        "Zoom maybe later",
        "Zoom done (completed)",
        "Chat done (completed)",
        "Zoom declined (completed)",
        "No response (completed)",
      ],
      "Zoom declined (completed)": [
        "Scheduling zoom"
      ],
      "No response (completed)": [
        "Scheduling zoom"
      ],
      "Zoom done (completed)": [],
      "Chat done (completed)": []
    }[status.to_sym].insert(0, status)
  # handle older greetings:
  rescue NoMethodError
    return [
      "Pending",
      "Joined!",
      "1st Email Sent",
      "2nd Email Sent",
      "Emailing",
      "No Response",
      "Rescheduling",
      "Follow Up",
      "Will Call",
      "Greet Scheduled",
      "Declined",
      "Welcomed",
      "Posted Intro",
      "Completed"
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