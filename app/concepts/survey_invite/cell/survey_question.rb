class SurveyInvite::Cell::SurveyQuestion < Cell::ViewModel
  def show
    render # renders app/cells/survey_invite/cell/survey_answer/show.haml
  end

  def survey_invite
    model[:survey_invite]
  end
  def survey_question
    model[:survey_question]
  end
  def position
    survey_question.position
  end
  def name
    "sq#{position}"
  end

  def question_type_class
    case survey_question.question_type
    when "Instructions"
      "survey-question-instructions"
    when "Question"
      "survey-question-question"
    end
  end

    def answer_type_class
    case survey_question.answer_type
    when "Yes/No"
      "survey-answer-yes-no"
    when "Multiple Choice"
      "survey-answer-multiple-choice"
    when "Essay"
      "survey-answer-essay"
    when "Rating"
      "survey-answer-rating"
    when "Scale"
      "survey-answer-scale"
    when "Number"
      "survey-answer-number"
    end
  end

  def question
    survey_question.question
  end

  def survey_answer
    survey_invite.survey_answers.where(survey_question_id: survey_question.id).first ||
    SurveyAnswer.new({
      survey_invite_id: survey_invite.id,
      survey_question_id: survey_question.id
    })
  end

  def user_answer
    answer = survey_answer.answer

    case survey_question.answer_type
    #----------------------
    when "Yes/No", "Multiple Choice"
      labels = survey_question.answer_labels ? survey_question.answer_labels.split("|") : ["Yes", "No"]
      # output vertical radio buttons with labels
      output = ""
      labels.each_with_index do |label, index|
        id = "#{name}-#{index}"
        output += "<input type='radio' id='#{id}' name='#{name}' value='#{label}' #{answer == label ? "checked" : nil} /> <label for ='#{id}'>#{label}</label>"
      end
      output
    #----------------------
    when "Essay"
      # output textarea
      "<textarea col='80'>#{answer}</textarea>"
    #----------------------
    when "Rating", "Scale"
      labels = survey_question.answer_labels ? survey_question.answer_labels.split("|") : ["0", "5"]
      # output horizontal radio buttons "1-N" and labels describing rating system
      "#{labels[0]} <input type='range' name='#{name}' min='#{labels[0]}' max='#{labels[1]}'> #{labels[1]}"
    #----------------------
    when "Number"
      # output text input
      "<input type='text' id='#{name}' name='#{name}' value='#{answer}' />"
    #----------------------
    else
      "unknown answer type" unless "Instructions" == survey_question.question_type
    end
  end

  def has_scale?
    survey_question.has_scale?
  end

  def scale
    return nil unless survey_question.has_scale?
    labels = (survey_question.scale_labels || "Not Important|Very Important").split("|")
    "#{labels[0]} <input type='range' name='#{name}' min='#{labels[0]}' max='#{labels[1]}'> #{labels[1]}"
  end
  
  def links
    link_to "Prev", survey_path(token: survey_invite.token, position: position-1) unless survey_question.first_question?
    link_to "Next", survey_path(token: survey_invite.token, position: position+1) unless survey_question.last_question?
    link_to "Finish", survey_path(token: survey_invite.token, position: position+1) if survey_question.last_question?
  end
end