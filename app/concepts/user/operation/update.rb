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
      change_log = "#{user.change_log}#{timestamp} by #{admin_name}:\n"
      user_params.each_pair do |attr, val|
        # check for association - yuck
        mattr = attr.to_s
        new_val = val.blank? ? "(blank)" : (mattr[-3,3] == "_id" ? User.find(val).name : val)
        old_val = user.send(attr)
        old_val = old_val.blank? ? "(blank)" : (mattr[-3,3] == "_id" ? User.find(old_val).name : old_val)
        mattr = mattr[-3,3] == "_id" ? mattr[0,mattr.length-3] : mattr
        change_log += "- #{mattr} changed: #{old_val} -> #{new_val}\n"

        val = val.blank? ? nil : val
        setter = attr.to_s + "="
        user.send(setter, val) # here is where we update the user
      end
      user.change_log = change_log
      user.save
    end
  end
end