module Survey::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Survey, :new)
      step Contract::Build(constant: Survey::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey)
    step Contract::Persist()
  end
end