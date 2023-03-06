module Survey::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Survey, :find_by)
      step Contract::Build(constant: Survey::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey)
    step Contract::Persist()
  end
end