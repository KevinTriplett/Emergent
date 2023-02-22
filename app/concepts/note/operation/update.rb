module Note::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Note, :find_by)
      step Contract::Build(constant: Note::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :note)
    step Contract::Persist()
  end
end