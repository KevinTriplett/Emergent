module User::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by)
      step Contract::Build(constant: User::Contract::Update)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step :log_changes
    step Contract::Persist()

    def log_changes(ctx, model:, current_user:, **)
      user = User.find(model.id)
      params = ctx[:params][:user]
      changes = user.changes(params)
      return true unless changes
      timestamp = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
      change_log = "#{user.change_log}#{timestamp} by #{current_user.name}:\n"
      changes.each_pair do |key, val|
        change_log += "- #{key} changed: #{val[0]} -> #{val[1]}\n"
      end
      user.update(change_log: change_log)
    end
  end
end