module Volunteer::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(User, :find_by, :token)
      step Contract::Build(constant: Volunteer::Contract::Update)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :user)
    step Contract::Persist()
  end
end