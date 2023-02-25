class Survey < ActiveRecord::Base
  has_many :survey_groups
  has_many :survey_questions, through: :survey_groups
  has_many :survey_invites
  has_many :users, through: :survey_invites

  def ordered_groups
    survey_groups.order(position: :asc)
  end

  def notes
    ordered_groups.collect(&:ordered_notes).flatten
  end

  def last_note_survey_group
    default_group = survey_groups.first
    return default_group if notes.blank?
    Note.where(survey_group_id: survey_groups.collect(&:id)).order(created_at: :asc).last.survey_group
  end

  def first_group?(group_position)
    group_position == 0
  end
  def last_group?(group_position)
    group_position == survey_groups.count-1
  end

  # for use in getting prev and next positions
  STATES = {
    seeking: 10,
    first_page_found: 20,
    group_boundary_crossed: 25,
    position_found: 30,
    second_page_found: 40
  }

  ######
  # PREV
  #####
  def get_prev_page_start_positions(survey_question)
    group_position = survey_question.group_position
    question_position = nil
    state = STATES[:seeking]

    if survey_question.at_group_beginning?
      return [-1, -1] if first_group?(group_position)
      group_position -= 1
      survey_question = survey_groups.where(position: group_position).first.ordered_questions.last
      state = STATES[:group_boundary_crossed]
    end

    # question <- skip
    # question <- skip
    # question <- current position (skip)
    # new page <- first new page (skip) and skip any multiple of new pages until question found
    # question <- #=> update question_position
    # question <- #=> update question_position
    # new page <- second new page break without updating question_position

    survey_question.ordered_questions.reverse.each do |sq|
      next if sq.position >= survey_question.position unless STATES[:group_boundary_crossed] == state
      if "New Page" == sq.question_type
        state = (STATES[:position_found] == state ? STATES[:second_page_found] : STATES[:first_page_found])
        break if STATES[:second_page_found] == state
        next # in case there are sequential new pages
      end
      question_position = sq.position
      state = STATES[:position_found]
    end

    [group_position, question_position || -1]
  end

  ######
  # NEXT
  #####
  def get_next_page_start_positions(survey_question)
    group_position = survey_question.group_position
    question_position = nil
    state = STATES[:seeking]

    if survey_question.at_group_ending?
      return [-1, -1] if last_group?(group_position)
      group_position += 1
      survey_question = survey_groups.where(position: group_position).first.ordered_questions.first
      state = STATES[:first_page_found]
    end

    # question <- update question_position and break
    # new page <- new page (skip) and any multiples of new pages until question found
    # question <- update question_position
    # question <- current_position (skip)
    # new page <- skip
    # question <- skip
    # question <- skip
    survey_question.ordered_questions.each_with_index do |sq, i|
      next if sq.position < survey_question.position
      if "New Page" == sq.question_type
        state = STATES[:first_page_found]
        next # in case there are sequential new pages
      end
      question_position = sq.position
      break if STATES[:first_page_found] == state
    end

    [group_position, question_position || -1]
  end
end
