module Note::Operation
  class Delete < Trailblazer::Operation
    step Model(Note, :find_by)
    step :delete

    def delete(ctx, model:, **)
      model.survey.notes.first.touch # to generate live view
      model.destroy
    end
  end
end