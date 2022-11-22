module Member::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Member, :new)
      step Contract::Build(constant: Member::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :member)
    step Contract::Persist()
  end
end