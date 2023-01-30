module SurveyAnswer::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyAnswer, :find_by)
      step Contract::Build(constant: SurveyAnswer::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_answer)
    step :nillify_scale
    step Contract::Persist()

    def nillify_scale(ctx, model:, **)
      survey_question = SurveyQuestion.find(model.survey_question_id)
      model.scale = nil unless survey_question.has_scale?
      true
    end
  end
end