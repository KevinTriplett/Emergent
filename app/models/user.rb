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
    header = data.shift
    headers = header.split("\t").collect(&:to_sym)

    data.each do |line|
      values = line.split("\t")

      model = {}
      headers.each_with_index do |head, i|
        model[head] = case head
        when :opt_out
          values[i].present?
        when :join_timestamp
          if values[i].present?
            ts = values[i].split("/")
            "20#{ts[2]}/#{ts[0]}/#{ts[1]}"
          end
        else
          values[i]
        end
      end
      model.compact!

      if model[:first_name] || model[:last_name]
        model[:name] = "#{model[:first_name]} #{model[:last_name]}"
      end
      id = model[:member_id]
      model[:profile_url] = "https://emergent-commons.mn.co/members/#{id}"
      model[:chat_url] = "https://emergent-commons.mn.co/chats/new?user_id=#{id}"

      user = find_by_member_id(id)

      if user
        puts "-------------------------------------------------\nupdating #{user.inspect} to #{model}"
        user.update model
      # else -- no because member might be in db w/o member_id
      #   puts "creating #{model}"
      #   User.create model
      end
    end
  end
end