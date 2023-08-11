class Survey::Cell::SurveyReport < Cell::ViewModel
  def show
    render # renders app/cells/survey/cell/survey_report/show.haml
  end

  def survey_invites
    model[:survey_invites]
  end
  def survey_question
    model[:survey_question]
  end

  def markdown
    @renderer ||= Redcarpet::Render::HTML.new({
      hard_wrap: true,
      safe_links_only: true,
      link_attributes: {target: "_blank"}
    })
    @markdown ||= Redcarpet::Markdown.new(@renderer, {
      autolink: true,
      tables: true,
      space_after_headers: true,
      strikethrough: true,
      highlight: true,
      underline: true
    })
  end

  def question
    markdown.render(survey_question.question) if survey_question.question
  end
  def scale_question
    return nil unless survey_question.has_scale?
    survey_question.scale_question
  end

  def question_type_class
    "survey-question-#{survey_question.question_type.downcase.gsub(" ", "-").gsub("/", "-")}"
  end
  def question_css_id
    "survey-question-#{survey_question.id}"
  end
  def name
    "sq-#{group_position}-#{question_position}"
  end

  def answer?
    !survey_question.na?
  end
  def voted?
    survey_question.vote? && survey_answer.votes > 0
  end
  def has_scale?
    survey_question.has_scale?
  end
end