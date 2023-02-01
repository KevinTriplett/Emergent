module SurveyQuestion::Operation
  class Patch < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(SurveyQuestion, :find_by)
      step :initialize_position
      step Contract::Build(constant: SurveyQuestion::Contract::Patch)

      def initialize_position(ctx, model:, params:, **)
        params[:model][:position] && model.position = params[:model][:position]
      end
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :model)
    step Contract::Persist()
  end
end