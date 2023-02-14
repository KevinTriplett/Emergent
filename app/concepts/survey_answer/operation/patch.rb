module SurveyAnswer::Operation
  class Patch < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyAnswer, :find_by, :survey_answer_token)
      step Contract::Build(constant: SurveyAnswer::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_answer)
    step :update_model

    def update_model(ctx, model:, params:, **)
      survey_answer = SurveyAnswer.find_by_token(params[:survey_answer_token])
      params[:model].each_pair do |attr, val|
        survey_answer.send("#{attr}=", val)
      end
      survey_answer.save
    end
  end
end