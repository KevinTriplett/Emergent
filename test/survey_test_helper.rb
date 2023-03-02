############################
# survey-specific test helpers

SURVEY_NAMES = %w(fabulous outstanding amazing spectacular impressive survey questions answers help input insight)
def random_survey_name
  @_last_random_survey_name = "#{ SURVEY_NAMES.sample } #{ SURVEY_NAMES.sample } #{ SURVEY_NAMES.sample }"
end
def last_random_survey_name
  @_last_random_survey_name
end

SURVEY_QUESTIONS = [
  "What's all this then?",
  "How do you work this?",
  "How did I get here?",
  "Where is my beautiful spouse?",
  "Where is that large automobile?",
  "What is that beautiful house?",
  "Where does that highway go to?",
  "Am I right?...Am I wrong?",
  "My God!...What have I done?",
  "What you gonna do when you get out of jail?",
  "What do you consider fun?",
  "Who took the money?",
  "Who took the money away?",
  "What was the place, what was the name?",
  "What do you know?",
  "Why, why, why, why start it over?",
]
def random_survey_question
  SURVEY_QUESTIONS.sample
end

SURVEY_LABELS = %w(Scale Left Right Oh Yeah Hell Up Down In Out Maybe Very Not Wow Lots Loads Tons Little Meh)
def random_survey_labels
  "#{ SURVEY_LABELS.sample } #{ SURVEY_LABELS.sample }|#{ SURVEY_LABELS.sample } #{ SURVEY_LABELS.sample }"
end

NOTE_TEXT = [
  "Here's a short note",
  "Here's a really long note but not really that long now that I look at it",
  "I think I'll switch to Lorem Ipsum text now",
  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris rutrum mi dolor. Proin eu diam nulla. Vivamus hendrerit metus risus, sollicitudin blandit nisi lacinia vitae. Aliquam sollicitudin elit vel congue pulvinar.",
  "Aenean at egestas dui, eget tristique sem. Aliquam iaculis consectetur est ut varius. Suspendisse potenti. Etiam in est velit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.",
  "Nunc a nunc vel ex convallis convallis. Mauris consequat dui nec pulvinar sagittis. Ut viverra dapibus nibh sit amet aliquet.",
  "t lectus libero, volutpat eget nunc vel, viverra varius dui. Morbi id orci mattis, pellentesque dolor in, egestas arcu. Ut a placerat dui. Fusce auctor augue interdum ante varius, nec porta dui scelerisque.",
  "Donec quis pretium nunc. Curabitur rutrum augue ornare libero malesuada rhoncus. Phasellus convallis vel mi tempor tincidunt. Phasellus dapibus et nulla vitae egestas. Etiam et lacinia nisl, sed blandit tortor.",
  "Maecenas tincidunt consectetur lacus maximus vehicula. Aliquam tincidunt velit a varius varius. Nullam condimentum feugiat risus at eleifend. In ullamcorper pellentesque imperdiet. Ut varius velit id ex porttitor auctor.",
  "Proin non orci non nunc blandit euismod et congue ex. Sed quis nisl laoreet, consequat nulla a, viverra turpis. Maecenas ac metus dignissim, dignissim ex in, ultricies odio. Quisque finibus nibh ut magna lacinia, a accumsan nisl lacinia.",
  "Proin iaculis venenatis varius. Cras sagittis dapibus varius.",
  "In id augue sit amet nunc tempus ultricies. Sed quis commodo ex.",
  "Etiam interdum et felis nec volutpat. Donec non orci ac arcu sagittis fringilla sit amet ac tortor.",
  "Cras sem nisl, efficitur porttitor ultrices id, sagittis et elit.",
  "Suspendisse accumsan ipsum quis arcu malesuada, a volutpat magna consequat. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.",
  "Sed id tincidunt sapien. In non porttitor turpis, at ultrices sem. Praesent at sem tortor. Praesent finibus urna metus, non vestibulum tellus feugiat non.",
  "Morbi pharetra accumsan massa eget faucibus. Vivamus porta vestibulum neque ut venenatis."
]
def random_note_text
  NOTE_TEXT.sample
end

def create_survey_with_result(params = {})
  Survey::Operation::Create.call(
    params: {
      survey: {
        name: params[:name],
        description: params[:description]
      },
      create_initial_questions: params[:create_initial_questions]
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
  SurveyGroup::Operation::Create.call(
    params: {
      survey_group: {
        name: params[:name],
        description: params[:description],
        votes_max: params[:votes_max],
        note_color: params[:note_color]
      },
      survey_id: survey_id
    }
  )
end

def create_survey_group(params = {})
  params[:name] ||= random_survey_name
  params[:description] ||= "this is the survey group description"
  params[:votes_max] ||= 5
  params[:note_color] ||= "#aabb44"
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
  params[:question] ||= random_survey_question
  params[:answer_type] ||= "Yes/No"
  params[:has_scale] ||= "0"
  params[:scale_labels] ||= random_survey_labels if params[:has_scale] != "0"
  params[:scale_question] ||= "How Important?" if params[:has_scale] != "0"
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
        text: params[:text],
        coords: params[:coords]
      }
    },
    survey_group_id: survey_group_id
  )
end

def create_note(params = {})
  params[:text] ||= random_note_text
  params[:coords] ||= "10:10"
  create_note_with_result(params)[:model]
end
