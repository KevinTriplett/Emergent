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
        # check for association
        new_val = val.blank? ? "(blank)" : (attr.to_s[-3,3] == "_id" ? User.find(val).name : val)
        old_val = user.send(attr).blank? ? "(blank)" : user.send(attr)
        change_log += "- #{attr} changed: #{old_val} -> #{new_val}\n"

        val = val.blank? ? nil : val
        setter = attr.to_s + "="
        user.send(setter, val)
      end
      changle_log = (user.change_log || "") + change_log
      user.change_log = change_log
      user.save
    end
  end
end