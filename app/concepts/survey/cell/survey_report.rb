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
  def names
    model[:names]
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
  def range_labels
    return unless survey_question.answer_labels
    labels = survey_question.answer_labels.split("|")
    "0 = #{labels[0]} ~:~ 10 = #{labels[1]}"
  end
  def scale_labels
    return unless survey_question.scale_labels
    labels = survey_question.scale_labels.split("|")
    "0 = #{labels[0]} ~:~ 10 = #{labels[1]}"
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

  def compile_ranges
    survey_answers = SurveyAnswer.where(survey_question_id: survey_question.id)
    answers = survey_answers.collect(&:answer).compact.map(&:to_i).sort! { |a, b| b <=> a } # high to low
    no_answers = survey_answers.size - answers.size
    size_answers = answers.size
    average_answer = answers.sum / size_answers unless 0 == size_answers
    scales = survey_answers.collect(&:scale).compact.sort! { |a, b| b <=> a } # high to low
    no_scales = survey_answers.size - scales.size
    size_scales = scales.size
    average_scale = scales.sum / size_scales unless 0 == size_scales
    {
      answers: answers,
      no_answers: no_answers,
      average_answer: average_answer,
      size_answers: size_answers,
      scales: scales,
      no_scales: no_scales,
      average_scale: average_scale,
      size_scales: size_scales
    }
  end
end