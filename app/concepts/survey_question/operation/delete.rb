module SurveyQuestion::Operation
  class Delete < Trailblazer::Operation
    step Model(SurveyQuestion, :find_by)
    step :delete
    step :reorder_positions

    def reorder_positions(ctx, model:, **)
      survey_group = model.survey_group
      survey_group.ordered_questions.each_with_index do |sq, i|
        sq.update position: i
      end
    end

    def delete(ctx, model:, **)
      model.destroy
    end
  end
end