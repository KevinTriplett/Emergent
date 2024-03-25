class Survey::Cell::SurveyNoteReport < Cell::ViewModel
  def show
    render # renders app/cells/survey/cell/survey_note_report/show.haml
  end

  def survey_questions
    model[:survey_questions]
  end
  def names
    model[:names]
  end

  def notes_ranked_with_votes
    survey_questions.collect do |sq|
      survey_answers = SurveyAnswer.where(survey_question_id: sq.id) #.sort { |a, b| b[:vote_count] <=> a[:vote_count] }
      answers = survey_answers.select {|sa| sa.vote_count > 0}
      vote_counts = survey_answers.collect(&:vote_count).select {|vc| vc > 0}
      zeros_count = survey_answers.count - vote_counts.count
      voters_count = vote_counts.count
      vote_counts.sort! { |a, b| b <=> a } # low to high
      total_votes = survey_answers.sum(&:vote_count)
      average = vote_counts.sum.to_f / vote_counts.size.to_f
      {
        note: sq.note,
        answers: answers,
        votes: total_votes,
        counts: vote_counts,
        zeros: zeros_count,
        voters: voters_count,
        average: average
      }
    end.sort {|a,b| b[:votes] <=> a[:votes]}
  end
end
