module SurveyGroup::Operation
  class Delete < Trailblazer::Operation
    step Model(SurveyGroup, :find_by)
    step :delete

    def delete(ctx, model:, **)
      model.destroy
    end
  end
end