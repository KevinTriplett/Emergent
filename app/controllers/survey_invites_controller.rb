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
    if :finished == state
      flash[:notice] = "Thank you for completing the survey"
      return redirect_to root_url # TODO: create nice finish page
    end
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
end