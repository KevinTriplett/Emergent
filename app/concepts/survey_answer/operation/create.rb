module SurveyAnswer::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyAnswer, :new)
      step :initialize_survey_invite_id
      step :initialize_survey_question_id
      step Contract::Build(constant: SurveyAnswer::Contract::Create)

      def initialize_survey_invite_id(ctx, model:, params:, **)
        params[:survey_invite_id] && model.survey_invite_id = params[:survey_invite_id]
      end

      def initialize_survey_question_id(ctx, model:, params:, **)
        params[:survey_question_id] && model.survey_question_id = params[:survey_question_id]
      end
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