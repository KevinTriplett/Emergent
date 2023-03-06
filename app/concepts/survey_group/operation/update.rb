module SurveyGroup::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyGroup, :find_by)
      step Contract::Build(constant: SurveyGroup::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_group)
    step Contract::Persist()
  end
end