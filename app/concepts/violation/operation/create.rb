module Violation::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Violation, :new)
      step Contract::Build(constant: Violation::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :violation)
    step Contract::Persist()
  end
end