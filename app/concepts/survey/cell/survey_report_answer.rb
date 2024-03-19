class Survey::Cell::SurveyReportAnswer < Cell::ViewModel
  def show
    render # renders app/cells/survey/cell/survey_report_answer/show.haml
  end

  def survey_invite
    model[:survey_invite]
  end
  def survey_question
    model[:survey_question]
  end
  def names
    model[:names]
  end
  def survey_answer
    survey_invite.survey_answer_for(survey_question.id)
  end

  def answer_type_class_name
    "survey-answer-#{survey_question.answer_type.downcase.gsub(" ", "-").gsub("/", "-")}"
  end
  def answer_type_class
    [answer_type_class_name, voted? ? "voted" : nil].compact.join(" ")
  end

  def answer?
    !survey_question.na?
  end
  def has_scale?
    survey_question.has_scale?
  end
  def voted?
    survey_question.vote? && survey_answer.votes > 0
  end
  def scale
    survey_answer.scale
  end

  def user_name
    survey_invite.user.name
  end
end