module Violation::Operation
  class Delete < Trailblazer::Operation
    step Model(Violation, :find_by)
    step :delete

    def delete(ctx, model:, **)
      model.destroy
    end
  end
end