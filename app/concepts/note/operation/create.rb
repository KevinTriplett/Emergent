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
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :note)
    step :determine_position
    step :create_survey_question
    step Contract::Persist()
    
    def determine_position(ctx, model:, **)
      model.position = model.notes.count
    end

    def create_survey_question(ctx, model:, params:, **)
      result = SurveyQuestion::Operation::Create.call(
        params: {
          survey_question: {
            question: params[:note][:text] || model.text,
            question_type: "Question",
            answer_type: "Vote"    
          },
          survey_group_id: model.survey_group_id,
        }
      )
      model.survey_question_id = result[:model].id if result.success?
    end
  end
end