module User::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by)
      step Contract::Build(constant: User::Contract::Update)
    end
    
    step Subprocess(Present)
    # step :print_user
    step Contract::Validate(key: :user)
    step Contract::Persist()

    def print_user(ctx, model:, **)
      puts "model = #{model.inspect}"
      puts "ctx = #{ctx.inspect}"
      true
    end
  end
end