class Survey < ActiveRecord::Base
  has_many :survey_groups, dependent: :destroy
  has_many :survey_questions, through: :survey_groups
  has_many :survey_invites, dependent: :destroy
  has_many :users, through: :survey_invites

  def ordered_groups
    survey_groups.order(position: :asc)
  end

  def notes
    ordered_groups.collect(&:ordered_notes).flatten
  end
  def ordered_questions
    ordered_groups.collect(&:ordered_questions).flatten
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
    current_position_found: 11,
    page_found: 20,
    first_page_found: 21,
    second_page_found: 22,
    seeking_second_page: 30,
    non_note_found: 31,
    note_found: 32
  }

  ######
  # PREV
  #####
  def prev_question_before_notes
    survey_question = notes.first.survey_question
    get_prev_page_start_positions(survey_question)
  end

  def notes_prev?(survey_question)
    ordered_questions.reverse.any? do |sq|
      next if sq.group_position >  survey_question.group_position
      next if sq.group_position == survey_question.group_position && sq.position >= survey_question.position
      break if sq.new_page?
      break if sq.survey_group_id != survey_question.survey_group_id && !sq.note?
      sq.note?
    end
  end

  def get_prev_page_start_positions(survey_question)
    group_position = question_position = prev_group_position = nil
    
    # | starting from the last question
    # |
    # V
    # question            <- skip
    # question            <- skip
    # question            <- current group/question position (skip)
    # new page/note/group <- start looking for next page/note/group
    # question            <- update question_position
    # question            <- update question_position
    # new page            <- second new page break without updating question_position
    state = STATES[:seeking]
    ordered_questions.reverse.each do |sq|
      new_group = prev_group_position != sq.group_position
      prev_group_position = sq.group_position

      if sq.id == survey_question.id
        state = STATES[:current_position_found]
        next
      end
      next if STATES[:seeking] == state
      if sq.new_page? || sq.note? || new_group
        break if STATES[:seeking_second_page] == state
        state = STATES[:first_page_found]
        next if sq.new_page? || sq.note? # in case there are sequential new pages or notes
      end
      next unless STATES[:first_page_found] == state || STATES[:seeking_second_page] == state
      group_position = sq.group_position
      question_position = sq.position
      state = STATES[:seeking_second_page]
    end

    [group_position || -1, question_position || -1]
  end

  ######
  # NEXT
  #####
  def next_question_before_notes
    survey_question = notes.last.survey_question
    get_next_page_start_positions(survey_question)
  end

  def notes_next?(survey_question)
    ordered_questions.any? do |sq|
      # puts "#{sq.group_position} / #{sq.position} -- #{survey_question.group_position} / #{survey_question.position}"
      next if sq.group_position <  survey_question.group_position
      next if sq.group_position == survey_question.group_position && sq.position <= survey_question.position
      break if sq.new_page?
      break if sq.survey_group_id != survey_question.survey_group_id && !sq.note?
      sq.note?
    end
  end

  def get_next_page_start_positions(survey_question)
    group_position = question_position = prev_group_position = nil
    
    # question          <- update question_position and break
    # new page/note/group <- skip
    # question          <- current group/question position
    # question          <- skip
    # question          <- skip
    # ^
    # |
    # | start from the first question
    state = STATES[:seeking]
    ordered_questions.each do |sq|
      new_group = prev_group_position != sq.group_position
      prev_group_position = sq.group_position

      if sq.id == survey_question.id
        state = STATES[:current_position_found]
        next
      end
      next if STATES[:seeking] == state
      if sq.new_page? || sq.note? || new_group
        state = STATES[:page_found]
        next if sq.new_page? || sq.note? # skip this and any sequential new pages or notes
      end
      next unless STATES[:page_found] == state
      group_position = sq.group_position
      question_position = sq.position
      break
    end

    [group_position || -1, question_position || -1]
  end
end
