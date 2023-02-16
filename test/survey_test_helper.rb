############################
# survey-specific test helpers

SURVEY_NAMES = %w(fabulous outstanding amazing spectacular impressive survey questions answers help input insight)
def random_survey_name
  @_last_random_survey_name = "#{ SURVEY_NAMES.sample } #{ SURVEY_NAMES.sample } #{ SURVEY_NAMES.sample }"
end

def last_random_survey_name
  @_last_random_survey_name
end

def create_survey_with_result(params = {})
  Survey::Operation::Create.call(
    params: {
      survey: {
        name: params[:name],
        description: params[:description]
      }
    }
  )
end

def create_survey(params = {})
  params[:name] ||= random_survey_name
  params[:description] ||= "this is the description"
  create_survey_with_result(params)[:model]
end

def create_survey_question_with_result(params = {})
  survey_id = params[:survey_id] || (params[:survey] && params[:survey].id) || create_survey.id
  SurveyQuestion::Operation::Create.call(
    params: {
      survey_question: {
        question_type: params[:question_type],
        question: params[:question],
        answer_type: params[:answer_type],
        has_scale: params[:has_scale],
        answer_labels: params[:answer_labels],
        scale_labels: params[:scale_labels],
        scale_question: params[:scale_question]
      },
      survey_id: survey_id
    }
  )
end

def create_survey_question(params = {})
  params[:question_type] ||= "Question"
  params[:question] ||= "What is your quest?"
  params[:answer_type] ||= "Yes/No"
  params[:has_scale] ||= "0"
  params[:scale_labels] ||= "Scale Left|Scale Right" if params[:has_scale]
  params[:scale_question] ||= "How Important?" if params[:has_scale]
  params[:answer_labels] ||= case params[:answer_type]
  when "Yes/No"
     "Yes|No"
  when "Multiple Choice"
    "One|Two|Three|Four|Five"
  when "Rating"
    "Low|High"
  else
    nil
  end
  create_survey_question_with_result(params)[:model]
end

def create_survey_invite_with_result(params = {})
  survey_id = params[:survey_id] || (params[:survey] && params[:survey].id) || create_survey.id
  user_id = params[:user_id] || (params[:user] && params[:user].id) || create_user.id
  SurveyInvite::Operation::Create.call(
    params: {
      survey_invite: {
        subject: params[:subject] || "This is hte subject",
        body: params[:body] || "This is hte body"
      },
      survey_id: survey_id,
      user_id: user_id,
      url: "https://domain.com/survey"
    }
  )
end

def create_survey_invite(params = {})
  create_survey_invite_with_result(params)[:model]
end

def create_survey_answer_with_result(params = {})
  survey_question_position = params[:survey_question_position] || 
    (params[:survey_question] && params[:survey_question].position) || 
    create_survey_question.position
  survey_invite_token = params[:survey_invite_token] || 
    (params[:survey_invite] && params[:survey_invite].token) || 
    create_survey_invite.token
  SurveyAnswer::Operation::Create.call(
    params: {
      survey_answer: {
        answer: params[:answer],
        scale: params[:scale]
      },
      position: survey_question_position,
      survey_invite_token: survey_invite_token
    }
  )
end

def create_survey_answer_non_operation(params = {})
  survey_invite = (params[:survey_invite_token] && SurveyInvite.find_by_token(params[:survey_invite_token])) || 
  params[:survey_invite] || create_survey_invite
  raise unless params[:survey_question_id]
  SurveyAnswer.create({
    survey_invite_id: survey_invite.id,
    survey_question_id: params[:survey_question_id],
    answer: params[:answer],
    scale: params[:scale]
  })
end

def create_survey_answer(params = {})
  params[:answer] ||= "this is my answer it is, yup"
  params[:scale] ||= 50
  # create_survey_answer_with_result(params)[:model]
  create_survey_answer_non_operation(params)
end
