module User::Operation
  class Approve < Trailblazer::Operation

    step Model(User, :find_by, :token)
    step :queue_approval_and_update_model

    def queue_approval_and_update_model(ctx, model:, admin:, **)
      return true if model.member_id # user already approved
      
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S UTC")
      model.change_log = "#{model.change_log}#{timestamp}\n- Join approval requested by #{admin.name}\n"
      # TODO can get out of sync, so make this programmatic from the hash
      model.status = "Scheduling Zoom"
      model.greeter_id ||= admin.id
      model.approved = true
      model.save
    end
  end
end
