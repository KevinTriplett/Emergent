class SurveyInvite::Cell::SurveyResults < Cell::ViewModel
  def show
    render # renders app/cells/survey_invite/cell/survey_results/show.haml
  end

  def survey_invite
    model[:survey_invite]
  end
  def survey_question
    model[:survey_question]
  end
  def survey_answer
    survey_invite.survey_answer_for(survey_question.id)
  end

  def group_position
    survey_question.group_position
  end
  def question_position
    survey_question.position
  end

  def question_type_class
    "survey-question-#{survey_question.question_type.downcase.gsub(" ", "-").gsub("/", "-")}"
  end

  def answer_type_class
    "survey-answer-#{survey_question.answer_type.downcase.gsub(" ", "-").gsub("/", "-")}"
  end

  def name
    "sq-#{group_position}-#{question_position}"
  end

  def group_css_id
    "survey-question-#{survey_question.id}"
  end
  def question_css_id
    "survey-question-#{survey_question.id}"
  end

  def answer_type?
    !survey_question.na?
  end

  def question
    survey_question.question
  end
  def answer
    survey_answer.answer
  end
  def scale
    survey_answer.scale
  end

  def user_answer
    case survey_question.answer_type
    #----------------------
    when "Yes/No", "Multiple Choice", "Essay", "Number", "Email"
      answer.blank? ? "(you left this answer blank)" : answer
    #----------------------
    when "Rating", "Range"
      left, right = survey_question.answer_labels ? survey_question.answer_labels.split("|") : ["0", "5"]
      # output horizontal radio buttons "1-N" and labels describing rating system
      "<label>#{left}</label>\
      <input disabled type='range' name='#{name}' value='#{answer}' min='0' max='10'>\
      <label>#{right}</label>"
    #----------------------
    when "Vote"
      "You gave this #{survey_answer.vote_count} votes"
    #----------------------
    when "NA"
    else
      "error: unknown answer type"
    end
  end

  def has_scale?
    survey_question.has_scale?
  end

  def answer_scale
    return nil unless survey_question.has_scale?
    left, right = (survey_question.scale_labels || "Not Important|Very Important").split("|")
    "<label>#{left}</label> <input disabled type='range' name='#{name}' value='#{scale}' min='0' max='10'> <label>#{right}</label>"
  end

  def scale_question
    return nil unless survey_question.has_scale?
    survey_question.scale_question
  end
end