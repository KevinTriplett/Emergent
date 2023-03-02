module Survey::Operation::SurveyHelper
  def create_survey_group(params = {})
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
    )
  end

  def create_survey_question_with_result(params = {})
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
    )
  end
end
