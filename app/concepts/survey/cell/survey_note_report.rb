class Survey::Cell::SurveyNoteReport < Cell::ViewModel
  def show
    render # renders app/cells/survey/cell/survey_note_report/show.haml
  end

  def survey_questions
    model[:survey_questions]
  end

  def notes_ranked_with_votes
    survey_questions.collect do |sq|
      survey_answers = SurveyAnswer.where(survey_question_id: sq.id)
      vote_counts = survey_answers.collect(&:vote_count)
      total_votes = survey_answers.sum(&:vote_count)
      {note: sq.note, votes: total_votes, counts: vote_counts}
    end.sort! do |a, b|
      b[:votes] <=> a[:votes]
    end
  end
end
