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
        has_scale: params[:has_scale]
      },
      survey_id: survey_id
    }
  )
end

def create_survey_question(params = {})
  params[:question_type] ||= "question"
  params[:question] ||= "What is your quest?"
  params[:answer_type] ||= "yes/no"
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
      user_id: user_id
    }
  )
end

def create_survey_invite(params = {})
  create_survey_invite_with_result(params)[:model]
end

def create_survey_answer_with_result(params = {})
  survey_question_id = params[:survey_question_id] || (params[:survey_question] && params[:survey_question].id) || create_survey_question.id
  survey_invite_id = params[:survey_invite_id] || (params[:survey_invite] && params[:survey_invite].id) || create_survey_invite.id
  SurveyAnswer::Operation::Create.call(
    params: {
      survey_answer: {
        answer: params[:answer],
        scale: params[:scale]
      },
      survey_question_id: survey_question_id,
      survey_invite_id: survey_invite_id
    }
  )
end

def create_survey_answer(params = {})
  params[:answer] ||= "this is my answer it is, yup"
  params[:scale] ||= 50
  create_survey_answer_with_result(params)[:model]
end
