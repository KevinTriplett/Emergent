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
    params[:survey_answer].each_pair do |attr, val|
      survey_answer.send("#{attr}=", val)
    end
    survey_answer.save ? (render json: {}) : (render head(:bad_request))
  end

  private

  def get_survey
    @position = params[:position].to_i
    @survey_invite = SurveyInvite.find_by_token(params[:token])
    return false if @survey_invite.nil? || @survey_invite.user.nil?

    @survey_questions = []
    @prev_position = @next_position = 0
    puts "position = #{@position}"
    @survey_invite.ordered_questions.each do |question|
      if question.position+1 < @position
        @prev_position = question.position+1 if "New Page" == question.question_type
      end
      next if question.position < @position
      if "New Page" == question.question_type
        @next_position = question.position+1
        break
      end
      @survey_questions.push(question)
    end
    true
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