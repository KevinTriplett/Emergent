class SurveyInvite::Cell::SurveyAnswer < Cell::ViewModel
  def show
    render # renders app/cells/survey_invite/cell/survey_answer/show.haml
  end

  def question
    survey_question = @survey_invite.survey_question.where(position: @position)
    case @survey_question.question_type
    when "New Page"
      # nop
    when "Instructions"
      %p.survey-question-instructions= sq.question
    when "Question"
      %p.survey-question= sq.question
    when "Branch"
      # TODO
    when "Scale"
      #output slider with labels
  
unless @survey_question.first_question?
  = link_to "Prev", survey_invite_survey_question_path(survey_invite_token: @survey_invite.token, position: position-1)
unless @survey_question.last_question?
  = link_to "Next", survey_invite_survey_question_path(survey_invite_token: @survey_invite.token, position: position+1)
if @survey_question.last_question?
  = link_to "Finish", survey_invite_survey_question_path(survey_invite_token: @survey_invite.token, position: position+1)