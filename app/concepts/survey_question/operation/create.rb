module SurveyQuestion::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :new)
      step :initialize_survey_id
      step :initialize_answer_type
      step :nillify_labels
      step :initialize_types
      step Contract::Build(constant: SurveyQuestion::Contract::Create)

      def initialize_survey_id(ctx, model:, params:, **)
        params[:survey_id] && model.survey_id = params[:survey_id]
      end

      def initialize_answer_type(ctx, params:, **)
        return true unless params[:survey_question]
        params[:survey_question][:answer_type] = "NA" if ["New Page","Instructions","Group Name","Branch"].index(params[:survey_question][:question_type])
        true
      end
  
      def nillify_labels(ctx, params:, **)
        return true unless params[:survey_question]
        params[:survey_question][:answer_labels] = nil if params[:survey_question][:answer_labels].blank?
        params[:survey_question][:scale_labels] = nil if params[:survey_question][:scale_labels].blank?
        true
      end

      def initialize_types(ctx, model:, params:, **)
        model.question_type ||= "Question"
        model.answer_type ||= "Essay"
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