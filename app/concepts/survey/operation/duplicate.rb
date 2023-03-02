module Survey::Operation
  class Duplicate < Trailblazer::Operation
    include SurveyHelper

    step :get_existing_survey
    step :create_new_survey
    step :clone_existing_survey

    def get_existing_survey(ctx, params:, **)
      ctx[:existing_survey] = Survey.find(params[:id])
    end

    def create_new_survey(ctx, existing_survey:, **)
      ctx[:model] = existing_survey.clone
      ctx[:model].name = "#{existing_survey.name} (duplicate)"
      ctx[:model].save
    end

    def clone_existing_survey(ctx, existing_survey:, model:, **)
      success = true
      existing_survey.survey_groups.each do |group|
        new_group = group.clone
        new_group.survey_id = model.id
        success = false unless group.save
        break unless success
        
        group.survey_questions.each do |question|
          new_question = question.clone
          new_question.survey_group_id = new_group.id
          success = false unless new_question.save
          break unless success

          next unless question.note
          new_note = question.note.clone
          new_note.survey_group_id = new_group.id
          new_note.survey_question_id = new_question.id
          success = false unless new_note.save
          break unless success
        end
        break unless success
      end
      model.destroy unless success
      success
    end
  
  end
end