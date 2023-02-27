class SurveyInvitesController < ApplicationController
  layout "survey"

  def show
    unless get_inivite
      flash[:notice] = "We're sorry, your survey was not found"
      return redirect_to root_url
    end

    sign_in(@survey_invite.user)
    update_invite_state

    if finished?
      if @survey_invite.subject = "Test Survey" && @survey_invite.body = "Test Survey"
        @url = admin_survey_url(@survey_invite.survey_id)
        @survey_invite.delete
      end
      @body_class = "finished"
      return render template: "survey_invites/finished"
    end

    get_survey
    get_urls
    @token = form_authenticity_token
  end

  def notes
    unless get_inivite
      flash[:notice] = "We're sorry, your survey was not found"
      return redirect_to root_url
    end

    sign_in(@survey_invite.user)

    get_survey
    get_notes_urls
    @token = form_authenticity_token
  end

  def patch
    survey_answer = get_survey_answer
    params[:survey_answer].each_pair do |attr, val|
      survey_answer.send("#{attr}=", val)
    end
    survey_answer.save ? (render json: {
      answer: survey_answer.reload.answer,
      scale: survey_answer.scale,
      vote_count: survey_answer.vote_count,
      votes_left: survey_answer.votes_left,
      group_position: survey_answer.group_position
    }) : (render head(:bad_request))
  end

  def vote
    survey_answer = get_survey_answer
    survey_answer.votes = params[:votes].to_i
    survey_answer.save ? (render json: {
      vote_count: survey_answer.vote_count,
      votes_left: survey_answer.votes_left
    }) : (render head(:bad_request))
  end

  private

  def get_inivite
    @survey_invite = SurveyInvite.find_by_token(params[:token])
    @survey_invite && @survey_invite.user
  end

  def finished?
    params[:group_position].to_i == -1 && params[:question_position].to_i == -1
  end

  def update_invite_state
    state = if params[:group_position].nil? && params[:question_position].nil?
      :opened
    elsif params[:group_position].to_i > 0 || params[:question_position].to_i > 0
      :started
    elsif params[:group_position].to_i == -1 && params[:question_position].to_i == -1
      :finished
    end
    @survey_invite.update_state(state)
  end

  def get_survey
    group_position = params[:group_position].to_i
    question_position = params[:question_position].to_i
    @survey = @survey_invite.survey
    @survey_group = @survey_invite.survey_groups.where(position: group_position).first
    @survey_question = @survey_group.survey_questions.where(position: question_position).first

    @survey_questions = []
    @survey_group.ordered_questions.collect do |question|
      next if question.position < question_position
      break if "New Page" == question.question_type
      @survey_questions.push(question)
    end
  end

  def get_urls
    prev_group_pos, prev_question_pos = @survey.get_prev_page_start_positions(@survey_question)
    next_group_pos, next_question_pos = @survey.get_next_page_start_positions(@survey_question)

    at_beginning = @survey_question.at_beginning?
    at_ending = @survey_question.at_ending?
    notes_next = @survey.notes_next?(@survey_question)
    notes_prev = @survey.notes_prev?(@survey_question)
    
    @prev_url = at_beginning ? nil : survey_path(token: @survey_invite.token, group_position: prev_group_pos, question_position: prev_question_pos)
    @next_url = at_ending ? nil : survey_path(token: @survey_invite.token, group_position: next_group_pos, question_position: next_question_pos)
    @finish_url = at_ending ? survey_path(token: @survey_invite.token, group_position: -1, question_position: -1) : nil
    @patch_url = survey_answer_patch_url(token: @survey_invite.token)
    @next_url = survey_notes_url(token: @survey_invite.token) if notes_next
    @prev_url = survey_notes_url(token: @survey_invite.token) if notes_prev
  end

  def get_notes_urls
    prev_group_pos, prev_question_pos = @survey.get_prev_page_start_positions_before_notes
    next_group_pos, next_question_pos = @survey.get_next_page_start_positions_after_notes

    at_beginning = @survey_question.at_beginning?
    at_ending = @survey_question.at_ending?
    notes_next = @survey.notes_next?(@survey_question)
    notes_prev = @survey.notes_prev?(@survey_question)
    
    @prev_url = at_beginning ? nil : survey_path(token: @survey_invite.token, group_position: prev_group_pos, question_position: prev_question_pos)
    @next_url = at_ending ? nil : survey_path(token: @survey_invite.token, group_position: next_group_pos, question_position: next_question_pos)
    @finish_url = at_ending ? survey_path(token: @survey_invite.token, group_position: -1, question_position: -1) : nil
    @patch_url = survey_answer_patch_url(token: @survey_invite.token)
    @next_url = survey_notes_url(token: @survey_invite.token) if notes_next
    @prev_url = survey_notes_url(token: @survey_invite.token) if notes_prev
  end

  def get_survey_answer
    group_position = params[:group_position].to_i
    question_position = params[:question_position].to_i
    survey_invite = SurveyInvite.find_by_token(params[:token])
    survey = survey_invite.survey
    survey_group = survey_invite.survey_groups.where(position: group_position).first
    survey_question = survey_group.survey_questions.where(position: question_position).first

    survey_invite.survey_answers.where(survey_question_id: survey_question.id).first ||
    SurveyAnswer.new({
      survey_invite_id: survey_invite.id,
      survey_question_id: survey_question.id
    })
  end
end