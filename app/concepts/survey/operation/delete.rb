module Survey::Operation
  class Delete < Trailblazer::Operation
    step Model(Survey, :find_by)
    step :delete

    def delete(ctx, model:, **)
      model.destroy
    end
  end
end