class Survey < ActiveRecord::Base
  has_many :survey_groups, dependent: :destroy
  has_many :survey_questions, through: :survey_groups
  has_many :survey_invites, dependent: :destroy
  has_many :users, through: :survey_invites

  def ordered_groups
    survey_groups.order(position: :asc)
  end

  def ordered_notes
    ordered_groups.collect(&:ordered_notes).flatten
  end
  def ordered_questions
    ordered_groups.collect(&:ordered_questions).flatten
  end

  # for use in getting questions and prev and next positions
  STATES = {
    seeking: 10,
    current_position_found: 11,
    first_question_found: 12,
    last_question_found: 13,
    page_found: 20,
    first_page_found: 21,
    second_page_found: 22,
    seeking_second_page: 30,
    non_note_found: 31,
    note_found: 32
  }

  def get_survey_questions(survey_question)
    state = STATES[:seeking]
    ordered_questions.select do |sq|
      state = STATES[:first_question_found] if sq.id == survey_question.id
      next if STATES[:seeking] == state
      state = STATES[:last_question_found] if sq.new_page? || sq.note?
      STATES[:last_question_found] != state
    end
  end

  def last_note_survey_group
    default_group = survey_groups.first
    return default_group if ordered_notes.blank?
    Note.where(survey_group_id: survey_groups.collect(&:id)).order(updated_at: :asc).last.survey_group
  end

  def fixup_positions
    ordered_groups.each_with_index do |group, i|
      group.update position: i if group.position != i
      group.ordered_notes.each_with_index do |note, j|
        note.update position: j if note.position != j
      end
      group.ordered_questions.each_with_index do |question, j|
        question.update position: j if question.position != j
      end
    end
  end

  ######
  # PREV
  #####
  def prev_question_before_notes
    survey_question = ordered_notes.first.survey_question
    get_prev_page_start_positions(survey_question)
  end

  def notes_prev?(survey_question)
    state = STATES[:seeking]
    ordered_questions.reverse.any? do |sq|
      # puts "#{sq.group_position} / #{sq.position} -- #{survey_question.group_position} / #{survey_question.position}"
      if sq.id == survey_question.id
        # puts "current position found"
        state = STATES[:current_position_found]
        next
      end
      next if STATES[:seeking] == state
      break if sq.new_page?
      sq.note?
    end
  end

  def get_prev_page_start_positions(survey_question)
    group_position = question_position = nil
    
    # | starting from the last question
    # |
    # V
    # question      <- skip
    # question      <- skip
    # question      <- current group/question position (skip)
    # new page/note <- start looking for next page/note/group
    # question      <- update question_position
    # question      <- update question_position
    # new page      <- second new page break without updating question_position
    state = STATES[:seeking]
    ordered_questions.reverse.each do |sq|
      if sq.id == survey_question.id
        state = STATES[:current_position_found]
        next
      end
      next if STATES[:seeking] == state
      if sq.new_page? || sq.note?
        break if STATES[:seeking_second_page] == state
        state = STATES[:first_page_found]
        next # in case there are sequential new pages or notes
      end
      next unless STATES[:first_page_found] == state || STATES[:seeking_second_page] == state
      group_position = sq.group_position
      question_position = sq.position
      state = STATES[:seeking_second_page]
    end

    [group_position || -1, question_position || -1]
  end

  def get_prev_page_start_positions_before_notes
    group_position = question_position = nil
    state = STATES[:seeking]
    # find first question after a new-page that's before notes section
    ordered_questions.reverse.each do |sq|
      if sq.note?
        state = STATES[:note_found]
        next
      end
      next if STATES[:seeking] == state
      if sq.new_page?
        break if STATES[:non_note_found] == state
        next # in case there are sequential new pages or notes
      end
      group_position = sq.group_position
      question_position = sq.position
      state = STATES[:non_note_found]
    end

    [group_position || -1, question_position || -1]
  end

  ######
  # NEXT
  #####
  def next_question_before_notes
    survey_question = ordered_notes.last.survey_question
    get_next_page_start_positions(survey_question)
  end

  def notes_next?(survey_question)
    state = STATES[:seeking]
    ordered_questions.any? do |sq|
      # puts "#{sq.group_position} / #{sq.position} -- #{survey_question.group_position} / #{survey_question.position}"
      if sq.id == survey_question.id
        # puts "current position found"
        state = STATES[:current_position_found]
        next
      end
      next if STATES[:seeking] == state
      break if sq.new_page?
      sq.note?
    end
  end

  def get_next_page_start_positions(survey_question)
    group_position = question_position = nil
    
    # question      <- update question_position and break
    # new page/note <- skip
    # question      <- skip
    # question      <- skip
    # question      <- current group/question position (skip)
    # ^             <- skip all previous questions
    # |
    # | start from the first question
    state = STATES[:seeking]
    ordered_questions.each do |sq|
      if sq.id == survey_question.id
        state = STATES[:current_position_found]
        next
      end
      next if STATES[:seeking] == state
      if sq.new_page? || sq.note?
        state = STATES[:page_found]
        next # skip this and any sequential new pages or notes
      end
      next unless STATES[:page_found] == state
      group_position = sq.group_position
      question_position = sq.position
      break
    end

    [group_position || -1, question_position || -1]
  end

  def get_next_page_start_positions_after_notes
    group_position = question_position = nil
    state = STATES[:seeking]
    # find first non-new-page after notes section
    ordered_questions.each do |sq|
      if sq.note?
        state = STATES[:note_found]
        next
      end
      next if STATES[:seeking] == state
      next if sq.new_page?
      group_position = sq.group_position
      question_position = sq.position
      break
    end

    [group_position || -1, question_position || -1]
  end
end
