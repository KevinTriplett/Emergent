module User::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by)
      step Contract::Build(constant: User::Contract::Update)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step :update_user

    def update_user(ctx, admin_name:, model:, params:, **)
      user_params = params[:user]
      user = User.find(params[:id])
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S UTC")
      new_change_log = "#{timestamp} by #{admin_name}:\n"
      user_params.each_pair do |attr, val|
        val = nil if val.blank?
        sattr, new_val, old_val = get_sattr_and_values(user, attr, val)
        old_val = check_for_notes_and_timestamp(user, sattr, old_val)
        new_change_log += "- #{sattr} changed: #{old_val} -> #{new_val}\n"
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
      end
      [sattr, new_val || "(blank)", old_val || "(blank)"]
    end

    def check_for_notes_and_timestamp(user, sattr, old_val)
      return old_val unless "notes" == sattr || "when_timestamp" == sattr
      return old_val unless user.change_log
      alog = user.change_log.split("\n")
      previous_change_timestamp = alog[-2].split(" by ")[0]
      return old_val if (Time.now < DateTime.parse(previous_change_timestamp) + 30.minutes)
      if alog.last.index("- #{sattr} changed: ")
        old_val = alog.last.split(": ")[1].split(" ->")[0]
        alog.pop # last old/new values
        alog.pop # timestamp of last change
        user.change_log = "#{alog.join("\n")}\n"
      end
      old_val
    end
  end
end