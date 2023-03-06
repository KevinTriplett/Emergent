module Survey::Operation::SurveyHelper
  def self.create_new_survey(params = {})
    params[:name] ||= "New Survey (rename)"
    params[:description] ||= "Replace this with the correct description"
    Survey::Operation::Create.call(
      params: {
        survey: {
          name: params[:name],
          description: params[:description]
        },
        create_initial_questions: params[:create_initial_questions]
      }
    )[:model]
  end

  def self.create_new_survey_group(params = {})
    params[:name] ||= "Contact Info"
    survey_id = params[:survey_id] || (params[:survey] && params[:survey].id)
    SurveyGroup::Operation::Create.call(
      params: {
        survey_group: {
          name: params[:name],
          description: params[:description],
          votes_max: params[:votes_max],
          note_color: params[:note_color]
        },
        survey_id: survey_id
      }
    )[:model]
  end

  def self.create_new_survey_question(params = {})
    params[:question_type] ||= "Question"
    survey_group_id = params[:survey_group_id] || (params[:survey_group] && params[:survey_group].id)
    SurveyQuestion::Operation::Create.call(
      params: {
        survey_question: {
          question_type: params[:question_type],
          question: params[:question],
          answer_type: params[:answer_type],
          has_scale: params[:has_scale],
          answer_labels: params[:answer_labels],
          scale_labels: params[:scale_labels],
          scale_question: params[:scale_question]
        },
        survey_group_id: survey_group_id
      }
    )[:model]
  end

  def self.create_new_note(params = {})
    survey_group_id = params[:survey_group_id] || 
      (params[:survey_group] && params[:survey_group].id)
    Note::Operation::Create.call(
      params: {
        note: {
          text: params[:text],
          coords: params[:coords]
        }
      },
      survey_group_id: survey_group_id
    )[:model]
  end
end
