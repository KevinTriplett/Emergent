module SurveyQuestion::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :new)
      step :initialize_survey_id
      step Contract::Build(constant: SurveyQuestion::Contract::Create)

      def initialize_survey_id(ctx, model:, params:, **)
        params[:survey_id] && model.survey_id = params[:survey_id]
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_question)
    step :determine_position
    step Contract::Persist()

    def determine_position(ctx, model:, **)
      survey = Survey.find(model.survey_id)
      model.position = survey.survey_questions.length
      true
    end
  end
end