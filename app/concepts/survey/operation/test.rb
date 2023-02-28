module Survey::Operation
  class Test < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Survey, :find_by)
      step Contract::Build(constant: Survey::Contract::Create)
    end
    
    step Subprocess(Present)
    step :create_survey_invite

    def create_survey_invite(ctx, model:, current_user:, url:, **)
      ctx[:survey_invite] = SurveyInvite::Operation::Create.call(
        params: {
          survey_invite: {
            subject: "Test Survey",
            body: "Test Survey"
          },
          survey_id: model.id,
          user_id: current_user.id,
          url: url
        }
      )[:model]
    end
  end
end