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
  def group_position
    survey_question.group_position
  end
  def question_position
    survey_question.position
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
    when "Range"
      "survey-answer-range"
    when "Number"
      "survey-answer-number"
    when "Vote"
      "survey-answer-vote"
    end
  end

  def name
    "sq-#{group_position}-#{question_position}"
  end

  def row_id
    "survey-question-#{group_position}-#{question_position}"
  end

  def answer_type?
    survey_question.answer_type != "NA"
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

  def survey_answer
    survey_invite.survey_answers.where(survey_question_id: survey_question.id).first ||
    SurveyAnswer.new({
      survey_invite_id: survey_invite.id,
      survey_question_id: survey_question.id
    })
  end

  def user_answer
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
      "<textarea cols='80'>#{answer}</textarea>"
    #----------------------
    when "Rating", "Range"
      left, right = survey_question.answer_labels ? survey_question.answer_labels.split("|") : ["0", "5"]
      # output horizontal radio buttons "1-N" and labels describing rating system
      "<label>#{left}</label>\
      <input type='range' name='#{name}' value='#{answer}' min='0' max='10'>\
      <label>#{right}</label>"
    #----------------------
    when "Number"
      # output text input
      "<input type='text' id='#{name}' name='#{name}' value='#{answer}' />"
    #----------------------
    when "Vote"
      count = survey_answer.vote_count || 0
      "<i class='vote-up bi-hand-thumbs-up-fill'></i>\
      <i class='vote-down bi-hand-thumbs-down-fill'></i>\
      <span class='vote-count'>#{count}</span>\
      (<span class='votes-left'>#{survey_answer.votes_left}</span> votes left)"
    #----------------------
    when "NA"
      # nothing
    #----------------------
    else
      "unknown answer type"
    end
  end

  def has_scale?
    survey_question.has_scale?
  end

  def answer_scale
    return nil unless survey_question.has_scale?
    left, right = (survey_question.scale_labels || "Not Important|Very Important").split("|")
    "<label>#{left}</label> <input type='range' name='#{name}' value='#{scale}' min='0' max='10'> <label>#{right}</label>"
  end

  def scale_question
    return nil unless survey_question.has_scale?
    survey_question.scale_question
  end
end