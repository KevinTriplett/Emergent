class Survey < ActiveRecord::Base
  has_many :survey_groups
  has_many :survey_questions, through: :survey_groups
  has_many :notes
  has_many :survey_invites
  has_many :users, through: :survey_invites

  def ordered_groups
    survey_groups.order(position: :asc)
  end

  def last_note_category
    default_category = "Category Name"
    return default_category if notes.blank?
    notes.order(created_at: :asc).last.category || default_category
  end

  def get_prev_page_start_positions(survey_question)
    group_position = survey_question.group_position

    if survey_question.at_group_beginning?
      group_position = [group_position-1, 0].max
      return [group_position, 0]
    end

    question_position = nil
    survey_question.ordered_questions.reverse.each do |sq|
      next if sq.position >= survey_question.position
      break if sq.question_type == "New Page" && question_position
      question_position = sq.position
    end

    [group_position, question_position || 0]
  end

  def get_next_page_start_positions(survey_question)
    group_position = survey_question.group_position

    if survey_question.at_group_ending?
      group_position = [group_position+1, survey_groups.count-1].min
      return [group_position, 0]
    end

    question_position = nil
    survey_question.ordered_questions.each do |sq|
      next if sq.position <= survey_question.position
      break if sq.question_type == "New Page" && question_position
      question_position = sq.position
    end

    [group_position, question_position || 0]
  end
end
