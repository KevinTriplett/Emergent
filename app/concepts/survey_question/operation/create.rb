module SurveyQuestion::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :new)
      step :initialize_survey_group_id
      step :initialize_answer_type
      step :nillify_labels
      step :initialize_types
      step Contract::Build(constant: SurveyQuestion::Contract::Create)

      def initialize_survey_group_id(ctx, model:, params:, **)
        params[:survey_group_id] && model.survey_group_id = params[:survey_group_id]
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
    step :create_note
    
    def determine_position(ctx, model:, params:, **)
      model.position = model.survey_questions.count
    end

    def create_note(ctx, model:, params:, **)
      return true unless params[:survey_question][:question_type] == "Note"
      note = Note.create(
        survey_question_id: model.id,
        survey_group_id: model.survey_group_id,
        text: model.question
      )
      note.update(position: note.notes.count - 1)
    end
  end
end