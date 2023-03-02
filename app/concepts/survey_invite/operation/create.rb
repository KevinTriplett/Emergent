module SurveyInvite::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyInvite, :new)
      step :initialize_survey_id
      step :initialize_user_id
      step :initialize_state
      step Contract::Build(constant: SurveyInvite::Contract::Create)

      def initialize_survey_id(ctx, model:, params:, **)
        params[:survey_id] && model.survey_id = params[:survey_id]
      end

      def initialize_user_id(ctx, model:, params:, **)
        params[:user_id] && model.user_id = params[:user_id]
        true
      end

      def initialize_state(ctx, model:, **)
        model.update_state(:created, false)
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_invite)
    step Contract::Persist()
  end
end