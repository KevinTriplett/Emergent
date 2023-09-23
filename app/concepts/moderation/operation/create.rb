module Moderation::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Moderation, :new)
      step Contract::Build(constant: Moderation::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :moderation)
    step Contract::Persist()
  end
end