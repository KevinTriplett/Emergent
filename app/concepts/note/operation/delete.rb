module Note::Operation
  class Delete < Trailblazer::Operation
    step Model(Note, :find_by)
    step :delete

    def delete(ctx, model:, **)
      model.destroy
    end
  end
end