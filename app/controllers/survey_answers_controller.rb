class SurveyAnswersController < AdminController
  layout "survey"

  def edit
    get_survery_answer
  end

  def patch
    get_survery_answer
    params[:survey_answer].each_pair do |attr, val|
      survey_answer.send("#{attr}=", val)
    end
    return survey_answer.save ? render json: {} : head(:bad_request)
    # TODO delete the TRB concept files
  end

  private

  def get_survery_answer
    survey_invite = SurveyInvite.find_by_token(params[:survey_invite_token])
    survey_question = survey_invite.survey_questions.where(position: params[:position])
    survey_answer = survey_invite.survey_answers.where(survey_question_id: survey_question.id)
    @survey_answer ||= SurveyAnswer.new({
      survey_invite_id: survey_invite.id,
      survey_question_id: survey_question.id
    })
  end
end
