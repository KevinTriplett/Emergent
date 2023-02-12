module User::Operation
  class Patch < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by, :token)
      step Contract::Build(constant: User::Contract::Patch)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :model)
    step :update_user

    def update_user(ctx, admin_name:, model:, params:, **)
      user_params = params[:model]
      user = User.find_by_token(params[:token])
      timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC")
      new_change_log = "#{timestamp} by #{admin_name}:\n"
      user_params.each_pair do |attr, val|
        val = nil if val.blank?
        sattr, new_val, old_val = get_sattr_and_values(user, attr, val)
        old_val = check_for_notes_and_timestamp(user, sattr, old_val)
        new_change_log += "- #{sattr} changed: #{old_val} -> #{new_val}\n"
        if "status" == sattr && user.when_timestamp
          new_change_log += "- when_timestamp changed: #{user.when_timestamp} -> (blank)\n"
          user.when_timestamp = nil
        end
        setter = "#{attr}="
        user.send(setter, val) # here is where we update the user
      end
      user.change_log = "#{user.change_log}#{new_change_log}"
      user.save
    end

    def get_sattr_and_values(user, attr, new_val)
      sattr = attr.to_s
      old_val = user.send(attr)
      old_val = nil if old_val.blank?
      # check for association
      if new_val && "_id" == sattr[-3,3]
        sattr = sattr[0, sattr.length-3] # truncate "_id"
        new_val = User.find(new_val).name
      elsif new_val && "when_timestamp" == sattr
        new_val = new_val.sub(/(?<=\d)T(?=\d)/, " ").sub(/.000Z/, " UTC")
      end
      [sattr, new_val || "(blank)", old_val || "(blank)"]
    end

    def check_for_notes_and_timestamp(user, sattr, old_val)
      return old_val unless user.change_log
      return old_val unless "notes" == sattr || "when_timestamp" == sattr

      alog = user.change_log.split("\n")
      # return if more than one attributes were last changed
      return old_val unless alog[-2].index(" by ")
      # or last change was not for this attribute
      return old_val unless alog.last.index("- #{sattr} changed: ")

      # return if the last change was not recent
      previous_change_timestamp = alog[-2].split(" by ")[0]
      return old_val unless (Time.now < (DateTime.parse(previous_change_timestamp) + 30.minutes))

      # okay, last change was recent and it was for this attribute, so replace it
      last_line = alog.pop # the old/new changed values
      alog.pop # throw away timestamp line of last change
      user.change_log = "#{alog.join("\n")}\n" # replace changelog
      last_line.split(": ")[1].split(" ->")[0] # and return the original changed value
    end
  end
end