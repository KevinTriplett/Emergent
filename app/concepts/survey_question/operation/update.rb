module SurveyQuestion::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :find_by)
      step Contract::Build(constant: SurveyQuestion::Contract::Update)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_question)
    step Contract::Persist()
  end
end