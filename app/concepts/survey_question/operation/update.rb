module SurveyQuestion::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :find_by)
      step :initialize_answer_type
      step :nillify_labels
      step Contract::Build(constant: SurveyQuestion::Contract::Update)
    
      def initialize_answer_type(ctx, model:, params:, **)
        return true unless params[:survey_question]
        params[:survey_question][:answer_type] = "NA" if ["New Page","Instructions","Group Name","Branch"].index(params[:survey_question][:question_type])
        true
      end
  
      def nillify_labels(ctx, model:, params:, **)
        return true unless params[:survey_question]
        params[:survey_question][:answer_labels] = nil if params[:survey_question][:answer_labels].blank?
        params[:survey_question][:scale_labels] = nil if params[:survey_question][:scale_labels].blank?
        true
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_question)
    step Contract::Persist()
  end
end