class SurveyInvitesController < ApplicationController
  layout "application"

  def show
    get_survery
    @survey_invite = SurveyInvite.find_by_token(params[:token])
    if @survey_invite.nil? || @survey_invite.user.nil?
      flash[:notice] = "I'm sorry, your survey was not found"
      return redirect_to root_url
    end
    sign_in(@survey_invite.user)
    @survey_invite.update(state: SurveyInvite::STATUS[:opened]) unless @survey_invite.opened?
  end

  private

  def get_survey_and_position
    @position = params[:position] || 0
    @survey_invite = SurveyInvite.find_by_token(params[:token])
  end

  def get_survery_questions
    @survey_questions = @survey_invite.survey_questions.where("position >= #{@position}")
    @survey_questions.select! {|sq| sq.question_type != }
  end

  def get_survery_answer
    get_survey_and_position
    @survey_question = survey_invite.survey.survey_questions.where(position: @position)
    @survey_answer = survey_invite.survey_answers.where(survey_question_id: @survey_question.id) ||
    SurveyAnswer.new({
      survey_invite_id: survey_invite.id,
      survey_question_id: survey_question.id
    })
  end
end