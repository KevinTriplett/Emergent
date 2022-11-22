module Greeter::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Greeter, :new)
      step Contract::Build(constant: Greeter::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :greeter)
    step Contract::Persist()
  end
end