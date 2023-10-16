class SurveyInvitesController < ApplicationController
  layout "survey"

  # ------------------------------------------------------------------------
  def new
    @survey = Survey.find_by_token(params[:survey_token])
    run SurveyInvite::Operation::Take::Present, survey_id: @survey.id, user_id: nil do |ctx|
      @form = ctx["contract.default"]
    end
  end

  def create
    @survey = Survey.find_by_token(params[:survey_token])
    user = User.find_by_email params[:user_email]
    invite = SurveyInvite.where(survey_id: @survey.id).where(user_id: user.id).first
    return redirect_to survey_path(token: invite.token) if invite

    _ctx = run SurveyInvite::Operation::Take, survey_id: @survey.id, user_id: user.id do |ctx|
      invite = ctx[:model]
      return redirect_to survey_path(token: invite.token)
    end
  
    flash[:notice] = user ? "We're sorry, something went wrong" : "We're sorry, your email address was not found"
    @form = _ctx["contract.default"]
    render :new, status: :unprocessable_entity
  end

  def show
    unless get_invite
      flash[:notice] = "We're sorry, your survey was not found"
      return redirect_to root_url
    end

    sign_in(@survey_invite.user)
    update_invite_state

    if finished?
      if "Test Survey" == @survey_invite.subject && "Test Survey" == @survey_invite.body
        @url = admin_survey_path(@survey_invite.survey_id)
        @survey_invite.delete
      else
        @survey_invite.update url: survey_show_results_url(token: @survey_invite.token)
        # @survey_invite.send_finished_survey_link
        # this will be cron job
      end
      @body_id = "finished"
      return render template: "survey_invites/finished"
    end

    get_survey
    get_urls
    initialize_answers
    if @survey_question.note?
      get_notes_and_survey_answers
      get_liveview_url
      get_template if @survey_group.stickies?
      @body_id = "notes"
      @body_class = @survey_group.get_note_style
    else
      get_survey_questions
      @body_id = "survey"
      @body_class = "survey"
    end
    @token = form_authenticity_token
  end

  # ------------------------------------------------------------------------

  def live_view
    get_invite
    return head(:bad_request) unless get_survey
    get_liveview_timestamp
    return head(:not_modified) if @live_view_timestamp == params[:timestamp]
    get_notes_and_survey_answers
    return render json: {
        results: @notes.collect {|note|
        {
          model: note,
          group_name: note.group_name,
          color: note.group_color
        }
      },
      timestamp: @live_view_timestamp
    }
  end

  # ------------------------------------------------------------------------
  
  def reset_votes
    get_invite
    get_survey
    @survey_invite.reset_votes(@survey_group.id)
    puts "***************************************************************"
    puts "   ======> got group #{@survey_group.name}"
    puts "   ======> got question #{@survey_question.question}"
    redirect_to survey_path(token: @survey_invite.token, survey_question_id: params[:survey_question_id])
  end
  
  # ------------------------------------------------------------------------

  def patch
    get_invite
    survey_answer = get_survey_answer
    params[:survey_answer].each_pair do |attr, val|
      survey_answer.send("#{attr}=", val)
    end
    survey_answer.save ? (render json: {
      answer: survey_answer.reload.answer,
      scale: survey_answer.scale,
      vote_count: survey_answer.vote_count,
      vote_thirds: survey_answer.vote_thirds,
      votes_left: survey_answer.votes_left,
      group_id: survey_answer.survey_group_id,
      question_id: survey_answer.survey_question_id,
      color: survey_answer.survey_group.note_color
    }) : (render head(:bad_request))
  end

  # ------------------------------------------------------------------------

  def show_results
    get_invite
    get_survey
    @survey_questions = {}
    @survey.ordered_questions.each do |sq|
      @survey_questions[sq.survey_group] ||= []
      @survey_questions[sq.survey_group].push sq
    end
    @body_id = "survey"
  end
  
  # ------------------------------------------------------------------------
  
  private

  def get_invite
    @survey_invite = SurveyInvite.find_by_token(params[:token])
    @survey_invite && @survey_invite.user
  end

  def get_survey
    @survey = @survey_invite.survey
    @survey_question = params[:survey_question_id] ?
      SurveyQuestion.find(params[:survey_question_id]) :
      @survey.ordered_questions.first
    @survey_group = @survey_question.survey_group
  end

  def get_survey_questions
    @survey_questions = {}
    @survey.get_survey_questions(@survey_question).each do |sq|
      @survey_questions[sq.survey_group] ||= []
      @survey_questions[sq.survey_group].push sq
    end
  end

  def get_notes_and_survey_answers
    @notes = @survey.get_notes(@survey_question)
    @survey_answers = []
    @notes.each do |note|
      @survey_answers.push @survey_invite.survey_answer_for(note.survey_question_id)
    end
    @notes.sort! do |a, b|
      vote_a = @survey_invite.survey_answer_for(a.survey_question_id).votes
      vote_b = @survey_invite.survey_answer_for(b.survey_question_id).votes
      vote_b <=> vote_a
    end
  end
  
  def get_liveview_timestamp
    @live_view_timestamp = @survey.last_updated_note_timestamp.picker_datetime
  end

  def get_template
    @template = Note.new(survey_group_id: @survey.survey_groups.first.id)
  end

  def get_urls
    prev_id = @survey.get_prev_page_start_question_id(@survey_question)
    next_id = @survey.get_next_page_start_question_id(@survey_question)

    @prev_url = prev_id == -1 ? nil : survey_path(token: @survey_invite.token, survey_question_id: prev_id)
    @next_url = next_id == -1 ? nil : survey_path(token: @survey_invite.token, survey_question_id: next_id)
    @finish_url = next_id == -1 ? survey_path(token: @survey_invite.token, survey_question_id: -1) : nil
    @patch_url = survey_patch_path(token: @survey_invite.token)
  end

  def get_survey_answer
    @survey_invite.survey_answer_for(params[:id])
  end

  # ------------------------------------------------------------------------

  def get_liveview_url
    return unless @survey.liveview
    time = Time.now - 4.hours
    return unless @notes.any? do |note|
      note.updated_at > time
    end
    get_liveview_timestamp
    @live_view_url = survey_live_view_path(@survey_invite.token, survey_question_id: @survey_question.id)
  end

  def finished?
    params[:survey_question_id].to_i == -1
  end

  def update_invite_state
    state = if params[:survey_question_id].nil?
      :opened
    elsif params[:survey_question_id].to_i > -1
      :started
    elsif params[:survey_question_id].to_i == -1
      :finished
    else
      return
    end
    @survey_invite.update_state(state)
  end

  def initialize_answers
    return if @survey_invite.survey_answers.count == @survey.survey_questions.count
    sa_sq_ids = @survey_invite.survey_answers.collect(&:survey_question_id)
    sq_ids = @survey.survey_questions.collect(&:id)
    # create answer for each question on this invite
    sq_ids.each do |sq_id|
      next if sa_sq_ids.index(sq_id) # skip -- answer already exists
      @survey_invite.survey_answers.create({
        survey_invite_id: @survey_invite.id,
        survey_question_id: sq_id,
        vote_count: 0
      })
    end
    # delete answer if question deleted
    sa_sq_ids.each do |sa_sq_id|
      next if sq_ids.index(sa_sq_id) # skip -- question exists
      @survey_invite.survey_answer_for(sa_sq_id).destroy
    end
  end
end