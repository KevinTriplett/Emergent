class SurveyInvitesController < ApplicationController
  layout "survey"

  # ------------------------------------------------------------------------
  def show
    unless get_inivite
      flash[:notice] = "We're sorry, your survey was not found"
      return redirect_to root_url
    end

    sign_in(@survey_invite.user)
    update_invite_state

    if finished?
      if @survey_invite.subject = "Test Survey" && @survey_invite.body = "Test Survey"
        @url = admin_survey_path(@survey_invite.survey_id)
        @survey_invite.delete
      end
      @body_id = "finished"
      return render template: "survey_invites/finished"
    end

    get_survey
    get_survey_questions
    initialize_answers
    get_urls
    @token = form_authenticity_token
    @body_id = "survey"
  end

  # ------------------------------------------------------------------------

  def notes
    unless get_inivite
      flash[:notice] = "We're sorry, your survey was not found"
      return redirect_to root_url
    end

    sign_in(@survey_invite.user)

    get_survey
    get_notes_and_survey_answers
    get_notes_urls
    enable_live_view?
    @token = form_authenticity_token
    @body_id = "notes"
  end

  # ------------------------------------------------------------------------

  def live_view
    get_inivite
    get_survey
    get_liveview_timestamp
    return head(:ok) if @live_view_timestamp == params[:timestamp]
    get_notes_and_survey_answers
    return render json: {
        results: @notes.collect {|note|
        {
          model: note,
          group_name: note.group_name,
          color: note.color
        }
      },
      timestamp: @live_view_timestamp
    }
  end
  
  # ------------------------------------------------------------------------

  def patch
    get_inivite
    survey_answer = get_survey_answer
    params[:survey_answer].each_pair do |attr, val|
      survey_answer.send("#{attr}=", val)
    end
    survey_answer.save ? (render json: {
      answer: survey_answer.reload.answer,
      scale: survey_answer.scale,
      vote_count: survey_answer.vote_count,
      votes_left: survey_answer.votes_left,
      group_position: survey_answer.group_position,
      color: survey_answer.survey_group.note_color
    }) : (render head(:bad_request))
  end

  # ------------------------------------------------------------------------

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
    elsif params[:group_position] == "0" && params[:question_position] == "0"
      return
    end
    @survey_invite.update_state(state)
  end

  def get_survey
    group_position = params[:group_position].to_i
    question_position = params[:question_position].to_i
    @survey = @survey_invite.survey
    @survey_group = @survey_invite.survey_groups.where(position: group_position).first
    @survey_question = @survey_group.survey_questions.where(position: question_position).first
    @survey
  end

  def get_survey_questions
    @survey_questions = {}
    @survey.get_survey_questions(@survey_question).each do |sq|
      @survey_questions[sq.survey_group] = [] unless @survey_questions[sq.survey_group]
      @survey_questions[sq.survey_group].push sq
    end
    @survey_questions
  end

  def get_notes_and_survey_answers
    @notes = @survey.ordered_notes
    @survey_answers = []
    @notes.each do |note|
      @survey_answers.push @survey_invite.get_survey_answer(note.survey_question_id)
    end
    @survey_answers
  end

  def enable_live_view?
    time = Time.now - 4.hours
    return unless @notes.any? do |note|
      note.updated_at > time
    end
    get_liveview_timestamp
    @live_view_url = survey_live_view_path(@survey_invite.token)
  end
  
  def get_liveview_timestamp
    @live_view_timestamp = @survey.last_updated_note_timestamp.picker_datetime
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
    @patch_url = survey_patch_path(token: @survey_invite.token)
    @next_url = survey_notes_path(token: @survey_invite.token) if notes_next # override
    @prev_url = survey_notes_path(token: @survey_invite.token) if notes_prev # override
  end

  def get_notes_urls
    prev_group_pos, prev_question_pos = @survey.get_prev_page_start_positions_before_notes
    next_group_pos, next_question_pos = @survey.get_next_page_start_positions_after_notes

    at_beginning = @survey.ordered_questions.first.note?
    at_ending = @survey.ordered_questions.last.note?
    
    @prev_url = at_beginning ? nil : survey_path(token: @survey_invite.token, group_position: prev_group_pos, question_position: prev_question_pos)
    @next_url = at_ending ? nil : survey_path(token: @survey_invite.token, group_position: next_group_pos, question_position: next_question_pos)
    @finish_url = at_ending ? survey_path(token: @survey_invite.token, group_position: -1, question_position: -1) : nil
    @patch_url = survey_patch_path(token: @survey_invite.token)
  end

  def get_survey_answer
    @survey_invite.get_survey_answer(params[:id])
  end

  def initialize_answers
    return if @survey_invite.survey_answers.count == @survey.survey_questions.count
    sa_sq_ids = @survey_invite.survey_answers.collect(&:survey_question_id)
    sq_ids = @survey.survey_questions.collect(&:id)
    sq_ids.each do |sq_id|
      next if sa_sq_ids.index(sq_id) # skip if answer already exists
      @survey_invite.survey_answers.create({
        survey_invite_id: @survey_invite.id,
        survey_question_id: sq_id,
        vote_count: 0
      })
    end
    sa_sq_ids.each do |sa_sq_id|
      next if sq_ids.index(sa_sq_id) # skip if question exists
      @survey_invite.survey_answers.where(survey_question_id: sa_sq_id).destroy_all
    end
  end
end