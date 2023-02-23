class SurveyInvitesController < ApplicationController
  layout "survey"

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
    @token = form_authenticity_token
    if :finished == state
      if @survey_invite.subject = "Test Survey" && @survey_invite.body = "Test Survey"
        @url = admin_survey_url(@survey_invite.survey_id)
        @survey_invite.delete
      end
      @body_class = "finished"
      return render template: "survey_invites/finished"
    end
    @url = survey_answer_patch_url(token: @survey_invite.token)
  end

  def patch
    survey_answer = get_survey_answer
    survey_invite = SurveyInvite.find_by_token(params[:token])
    params[:survey_answer].each_pair do |attr, val|
      survey_answer.send("#{attr}=", val)
    end
    survey_answer.save ? (render json: {
      answer: survey_answer.reload.answer,
      scale: survey_answer.reload.scale,
      vote_count: survey_answer.reload.vote_count,
      votes_left: survey_invite.votes_left
    }) : (render head(:bad_request))
  end

  private

  def get_survey
    @survey_invite = SurveyInvite.find_by_token(params[:token])
    return false if @survey_invite.nil? || @survey_invite.user.nil?

    group_position = params[:group_position].to_i
    question_position = params[:question_position].to_i
    survey = @survey_invite.survey
    survey_group = @survey_invite.survey_groups.where(position: group_position).first
    survey_question = survey_group.survey_questions.where(position: question_position).first

    @prev_group_pos, @prev_question_pos = survey.get_prev_page_start_positions(survey_question)
    @next_group_pos, @next_question_pos = survey.get_next_page_start_positions(survey_question)

    @survey_questions = []
    survey_group.ordered_questions.each do |question|
      next if question.position < question_position
      break if "New Page" == question.question_type
      @survey_questions.push(question)
    end
    !@survey_questions.empty?
  end

  def get_survey_answer
    position = params[:position].to_i
    survey_invite = SurveyInvite.find_by_token(params[:token])
    survey_question = survey_invite.survey_questions.where(position: position).first
    
    survey_invite.survey_answers.where(survey_question_id: survey_question.id).first ||
    SurveyAnswer.new({
      survey_invite_id: survey_invite.id,
      survey_question_id: survey_question.id
    })
  end
end