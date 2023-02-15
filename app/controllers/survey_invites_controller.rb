class SurveyInvitesController < ApplicationController
  layout "application"

  def show
    unless get_survey
      flash[:notice] = "We're sorry, your survey was not found"
      return redirect_to root_url
    end
    sign_in(@survey_invite.user)
    state = case @position.to_i
    when nil
      :opened
    when -1
      :finished
    else
      :started
    end
    @survey_invite.update_state(state)
  end

  private

  def get_survey
    @position = params[:position].to_i
    @survey_invite = SurveyInvite.find_by_token(params[:token])
    return if @survey_invite.nil? || @survey_invite.user.nil?

    next_question = false
    @survey_questions = []
    @survey_invite.survey_questions.each do |question|
      next if next_question || question.position < @position
      next_question = ("New Page" == question.question_type)
      @survey_questions.push(question) unless next_question
    end
  end
end