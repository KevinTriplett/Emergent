module User::Operation
  class Approve < Trailblazer::Operation

    step Model(User, :find_by, :token)
    step :queue_approval
    step :update_model

    def queue_approval(ctx, model:, admin:, **)
      return true if model.member_id # user already approved
      model.approved = true
      timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S UTC")
      model.change_log = "#{model.change_log}#{timestamp}\n- Join approval requested by #{admin.name}\n"
    end

    def update_model(ctx, model:, admin:, **)
      # TODO can get out of sync, so make this programmatic from the hash
      model.status = "Scheduling Zoom"
      model.greeter_id ||= admin.id
      model.save
    end
  end
end
