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
  params[:description] ||= "this is the survey description"
  create_survey_with_result(params)[:model]
end

def create_survey_group_with_result(params = {})
  survey_id = params[:survey_id] || 
    (params[:survey] && params[:survey].id) || 
    create_survey.id
  result = SurveyGroup::Operation::Create.call(
    params: {
      survey_group: {
        name: params[:name],
        description: params[:description],
        votes_max: params[:votes_max]
      },
      survey_id: survey_id
    }
  )
  result
end

def create_survey_group(params = {})
  params[:name] ||= random_survey_name
  params[:description] ||= "this is the survey group description"
  params[:votes_max] ||= 5
  create_survey_group_with_result(params)[:model]
end

def create_survey_question_with_result(params = {})
  survey_group_id = params[:survey_group_id] || 
    (params[:survey_group] && params[:survey_group].id) || 
    create_survey_group.id
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
      survey_group_id: survey_group_id
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
  survey_id = params[:survey_id] || 
    (params[:survey] && params[:survey].id) || 
    create_survey.id
  user_id = params[:user_id] || 
    (params[:user] && params[:user].id) || 
    create_user.id
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

def create_survey_answer(params = {})
  params[:answer] ||= "this is my answer it is, yup"
  params[:scale] ||= 50
  survey_invite_id = (params[:survey_invite_token] && SurveyInvite.find_by_token(params[:survey_invite_token]).id) || 
    (params[:survey_invite] && params[:survey_invite].id) ||
    params[:survey_invite_id] ||
    create_survey_invite.id
  survey_question_id = (params[:survey_question] && params[:survey_question].id) || 
    params[:survey_question_id] ||
    create_survey_question.id
  SurveyAnswer.create({
    survey_invite_id: survey_invite_id,
    survey_question_id: survey_question_id,
    answer: params[:answer],
    scale: params[:scale]
  })
end

def create_note_with_result(params = {})
  survey_group_id = params[:survey_group_id] || 
    (params[:survey_group] && params[:survey_group].id) || 
    create_survey_group.id
  Note::Operation::Create.call(
    params: {
      note: {
        survey_group_id: survey_group_id,
        text: params[:text],
        color: params[:color],
        coords: params[:coords]
      },
      survey_group_id: survey_group_id
    }
  )
end

def create_note(params = {})
  params[:text] ||= "this is the text"
  params[:color] ||= "#ffffff"
  params[:coords] ||= "10:10"
  create_note_with_result(params)[:model]
end
