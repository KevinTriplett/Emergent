class User < ActiveRecord::Base

  def self.import_users
    file = File.open "tmp/import.tsv"
    data = file.readlines.map(&:chomp)
    file.close

    puts "header row = #{data.shift}" # first line is headers
    # first_name,last_name,email,member_id,join_date,join_timestamp
    data.each do |line|
      first_name, last_name, email, member_id, x, join_timestamp, location, time_zone, country = line.split("\t")
      location = location.gsub(/\"/, "") if location
      name = "#{first_name} #{last_name}"
      profile_url = "https://emergent-commons.mn.co/members/#{member_id}"
      chat_url = "https://emergent-commons.mn.co/chats/new?user_id=#{member_id}"

      if find_by_email(email)
        puts "updating #{name}"
        user = find_by_email(email)
        user.update(name: name)
        user.update(first_name: first_name)
        user.update(last_name: last_name)
        # user.update(email: email)
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
          email: email,
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