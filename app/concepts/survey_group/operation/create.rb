module SurveyGroup::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyGroup, :new)
      step :initialize_survey_id
      step Contract::Build(constant: SurveyGroup::Contract::Create)

      def initialize_survey_id(ctx, model:, params:, **)
        params[:survey_id] && model.survey_id = params[:survey_id]
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey_group)
    step :determine_position
    step Contract::Persist()

    def determine_position(ctx, model:, **)
      model.position = model.survey.survey_groups.count
      true
    end
  end
end