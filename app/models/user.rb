class User < ActiveRecord::Base
  belongs_to :greeter, class_name: "User", optional: true
  belongs_to :shadow_greeter, class_name: "User", optional: true
  has_secure_token

  def ensure_token
    update(token: User.generate_unique_secure_token) if token.nil?
  end

  def generate_session_token
    # do not generate a new session_token bc that would break all other session_tokens
    update(session_token: SecureRandom.urlsafe_base64) unless session_token
    session_token
  end

  def has_role(role)
    true # TODO: implement
  end

  def notes_abbreviated
    notes ? "#{notes[0..16]}#{notes_ellipsis(16)}" : nil
  end

  def notes_ellipsis(len)
    notes.length > len ? "..." : nil
  end

  def get_status_options
    {
      "Pending": [],
      "Request Declined": [],
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
end