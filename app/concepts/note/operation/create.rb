module Note::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Note, :new)
      step :initialize_survey_group_id
      step :initialize_note
      step Contract::Build(constant: Note::Contract::Create)

      def initialize_survey_group_id(ctx, model:, survey_group_id:, **)
        survey_group_id && model.survey_group_id = survey_group_id
      end

      def initialize_note(ctx, model:, params:, **)
        model.text = "Click here to edit"
        model.color = model.survey_group.note_color || "#FFFF99"
        true
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :note)
    step :determine_position
    step Contract::Persist()
    
    def determine_position(ctx, model:, **)
      model.position = model.notes.count
    end
  end
end