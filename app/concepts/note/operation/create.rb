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
        model.text = params[:note][:text] || "Click here to edit"
        model.coords = "0:0"
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :note)
    step :determine_position
    step :determine_z_index
    step :create_survey_question
    step :create_survey_answers
    step Contract::Persist()
    
    def determine_position(ctx, model:, **)
      model.position = model.notes.count
    end

    def determine_z_index(ctx, model:, **)
      model.z_index = model.survey.max_z_index + 1
    end

    def create_survey_question(ctx, model:, params:, **)
      survey_question = SurveyQuestion.create(
        survey_group_id: model.survey_group_id,
        question: model.text,
        question_type: "Note",
        answer_type: "Vote"
      )
      survey_question.update(position: survey_question.survey_questions.count - 1)
      model.survey_question_id = survey_question.id
    end

    def create_survey_answers(ctx, model:, **)
      SurveyInvite.where(survey_id: model.survey_id).each do |invite|
        invite.survey_answers.create({
          survey_invite_id: invite.id,
          survey_question_id: model.survey_question_id,
          vote_count: 0
        })
      end
    end
  end
end