class Survey < ActiveRecord::Base
  include Operation::SurveyHelper

  has_many :survey_groups, dependent: :destroy
  has_many :survey_invites, dependent: :destroy
  
  has_many :survey_questions, through: :survey_groups
  has_many :notes, through: :survey_groups
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

  def last_updated_note_timestamp
    # group color may have been updated
    note = notes.order(updated_at: :asc).last
    group = survey_groups.order(updated_at: :asc).last
    note.updated_at > group.updated_at ? note.updated_at : group.updated_at
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
  # ------------------------------------------------------------------------
  # PREV
  #####
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
  # ------------------------------------------------------------------------
  # NEXT
  #####
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

  # ------------------------------------------------------------------------

  def self.import_sticky_notes
    file = File.open "tmp/sticky-import.tsv"
    data = file.readlines.map(&:chomp)
    file.close

    # check first row for correct file format
    headers = data.shift
    correct_headers = [
      "Miro Board / Group",
      "Group",
      "Text",
      "Vision",
      "Mission",
      "Value",
      "Action",
      "Practice",
      "Being"
    ].join("\t")
    unless headers == correct_headers
      puts "header row = #{headers}" # first line is headers
      puts "should be  = #{correct_headers}"
      return
    end

    prev_group_number = new_survey = nil
    column = row = 0

    data.each do |line|
      url, group_number, text, is_vision, is_mission, is_value, is_action, is_practice, is_being  = line.split("\t")
      puts "line = #{line}"

      if group_number != prev_group_number
        new_survey = Operation::SurveyHelper::create_new_survey({
          name: "Survey for group #{group_number}",
          description: "Voting survey",
          create_initial_questions: true
        })
        raise "something went wrong with survey creation" unless new_survey
        prev_group_number = group_number
      end

      group_name = if "TRUE" == is_vision
        "Vision"
      elsif "TRUE" == is_mission
        "Mission"
      elsif "TRUE" == is_value
        "Value"
      elsif "TRUE" == is_action
        "Action"
      elsif "TRUE" == is_practice
        "Practice"
      elsif "TRUE" == is_being
        "Being"
      else
        raise "No group name found for #{line}"
      end

      new_survey_group = new_survey.survey_groups.where(name: group_name).first
      if new_survey_group.nil?
        new_survey_group = Operation::SurveyHelper::create_new_survey_group({
          survey: new_survey,
          name: group_name,
          description: "change this description",
          votes_max: 30,
          note_color: case group_name
          when "Vision"
            "#f7f7ad"
          when "Mission"
            "#c3edc0"
          when "Value"
            "#b3d4e8"
          else
            "#aaffaa"
          end
        })
        raise "something went wrong with group creation / find" unless new_survey_group
        new_survey_group.update position: new_survey.reload.survey_groups.count-1
        column = row = 0
      end

      left = (200 * (column + new_survey_group.position - 1)) + 30
      top = (185 * row) + 130

      row += 1
      if row > 4
        column += 1
        row = 0
      end

      new_note = Operation::SurveyHelper::create_new_note({
        survey_group: new_survey_group,
        text: text,
        coords: "#{left}:#{top}"
      })
      raise "something went wrong with note creation" unless new_note
      new_note.update position: new_survey_group.reload.survey_questions.count-1
      new_note.survey_question.update position: new_survey_group.reload.survey_questions.count-1

    end
  end

end
