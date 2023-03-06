module SurveyInvite::Operation
  class Delete < Trailblazer::Operation
    step Model(SurveyInvite, :find_by)
    step :delete

    def delete(ctx, model:, **)
      model.destroy
    end
  end
end