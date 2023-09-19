module SurveyInvite::Operation
  class Take < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyInvite, :new)
      step :initialize_id
      step :initialize_state
      step Contract::Build(constant: SurveyInvite::Contract::Take)

      def initialize_id(ctx, model:, survey_id:, user_id:, **)
        model.user_id = user_id # can be nil
        survey_id && model.survey_id = survey_id
      end

      def initialize_state(ctx, model:, **)
        model.update_state(:opened, false)
      end
    end
    
    step Subprocess(Present)
    # step Contract::Validate(key: :survey_invite)
    step Contract::Persist()
  end
end