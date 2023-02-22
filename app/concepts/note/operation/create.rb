module Note::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Note, :new)
      step :initialize_survey_id
      step :initialize_note
      step Contract::Build(constant: Note::Contract::Create)

      def initialize_survey_id(ctx, model:, params:, **)
        params[:survey_id] && model.survey_id = params[:survey_id]
      end

      def initialize_note(ctx, model:, params:, **)
        params[:note][:text] ||= "text"
        params[:note][:category] ||= model.survey.last_note_category
        true
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :note)
    step Contract::Persist()
  end
end