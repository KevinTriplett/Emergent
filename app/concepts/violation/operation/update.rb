module Violation::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Violation, :find_by)
      step Contract::Build(constant: Violation::Contract::Create) # reuse create contract
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :violation)
    step Contract::Persist()
  end
end