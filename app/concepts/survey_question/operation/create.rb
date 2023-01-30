module SurveyQuestion::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :new)
      step :initialize_survey_id
      step Contract::Build(constant: SurveyQuestion::Contract::Create)

      def initialize_survey_id(ctx, model:, **)
        ctx[:survey_id] && model.survey_id = ctx[:survey_id]
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_question)
    step :determine_order
    step Contract::Persist()

    def determine_order(ctx, model:, **)
      survey = Survey.find(model.survey_id)
      model.order = survey.survey_questions.length
      true
    end
  end
end