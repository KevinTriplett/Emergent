module User::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by)
      step Contract::Build(constant: User::Contract::Create) # reuse the validations
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
  end
end