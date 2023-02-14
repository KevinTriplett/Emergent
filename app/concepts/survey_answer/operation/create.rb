module SurveyAnswer::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step :get_model
      step Contract::Build(constant: SurveyAnswer::Contract::Create)

      def get_model(ctx, **)
        survey_invite = SurveyInvite.find_by_token(ctx[:survey_invite_token])
        survey_question = survey_invite.survey_questions.where(position: ctx[:position])
        survey_answer = survey_invite.survey_answers.where(survey_question_id: survey_question.id)
        ctx[:model] = survey_answer || SurveyAnswer.new({
          survey_invite_id: survey_invite.id,
          survey_question_id: survey_question.id
        })
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_answer)
    step :nillify_scale
    step Contract::Persist()

    def nillify_scale(ctx, model:, **)
      survey_question = SurveyQuestion.find(model.survey_question_id)
      model.scale = nil unless survey_question.has_scale?
      true
    end
  end
end