class User < ActiveRecord::Base
  belongs_to :greeter, class_name: "User", optional: true
  belongs_to :shadow_greeter, class_name: "User", optional: true
  has_many :survey_invites, dependent: :destroy
  has_many :surveys, through: :survey_invites
  has_secure_token
  rolify

  def revoke_tokens
    # update(token: nil) # NB: don't nil token, it breaks views
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

  def questions_responses_array
    (questions_responses || []).split(" -:- ").collect { |qna| qna.split("\\") }
  end

  def lock
    update locked: true
  end
  def unlock
    update locked: false
  end

  def notes_abbreviated
    notes ? "#{notes[0..16]}#{notes_ellipsis(16)}" : nil
  end

  def notes_ellipsis(len)
    notes.length > len ? "..." : nil
  end

  def get_status_options
    {
      "Pending": [
        "Clarification Needed"
      ],
      "Clarification Needed": [
        "Request Declined",
        "Scheduling Zoom"
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
        "Zoom Declined (completed)",
        "Chat Done (completed)",
        "No Response (completed)",
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
    correct_headers = "Member ID,First Name,Last Name,Email Address"
    unless headers == correct_headers
      puts "header row = #{headers}" # first line is headers
      puts "should be  = #{correct_headers}"
      return
    end

    data.each do |line|
      member_id, first_name, last_name, email = line.split("\t")
      name = "#{first_name} #{last_name}"
      profile_url = member_id.present? ? "https://emergent-commons.mn.co/members/#{member_id}" : nil
      chat_url = member_id.present? ? "https://emergent-commons.mn.co/chats/new?user_id=#{member_id}" : nil

      user = email.present? ? find_by_email(email) : find_by_name(name)
      if user
        puts "updating #{name}"
        user.update(name: name)
        user.update(first_name: first_name)
        user.update(last_name: last_name)
        user.update(email: email.downcase) if email.present?
        user.update(member_id: member_id) if member_id.present?
        user.update(profile_url: profile_url) if profile_url.present?
        user.update(chat_url: chat_url) if chat_url.present?
      else
        puts "creating #{name}"
        create({
          name: name,
          first_name: first_name,
          last_name: last_name,
          email: (email || "").downcase,
          member_id: member_id,
          profile_url: profile_url,
          chat_url: chat_url,
          status: "existing"
        })
      end
    end
  end
end