module SurveyQuestion::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :new)
      step :initialize_survey_id
      step :initialize_question_type
      step :initialize_answer_type
      step Contract::Build(constant: SurveyQuestion::Contract::Create)

      def initialize_survey_id(ctx, model:, params:, **)
        params[:survey_id] && model.survey_id = params[:survey_id]
      end

      def initialize_question_type(ctx, model:, **)
        model.question_type = "Question"
      end

      def initialize_answer_type(ctx, model:, **)
        model.answer_type = "Essay"
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