module SurveyQuestion::Operation
  class Update < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :find_by)
      step :na_answer_type
      step Contract::Build(constant: SurveyQuestion::Contract::Update)
    
      def na_answer_type(ctx, model:, **)
        model.answer_type = "NA" if ["New Page","Instructions"].index(model.question_type)
        true
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_question)
    step Contract::Persist()
    step :nillify_labels

    def nillify_labels(ctx, model:, **)
      model.update(answer_labels: nil) if model.answer_labels.blank?
      model.update(scale_labels:  nil) if model.scale_labels.blank?
      true
    end
  end
end