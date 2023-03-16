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
    seeking_question: 14,
    seeking_non_note: 15,
    page_found: 20,
    first_page_found: 21,
    second_page_found: 22,
    seeking_second_page: 30,
    non_note_found: 31,
    note_found: 32,
    last_note_found: 33,
    finished: 40
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

  def get_notes(survey_question)
    state = STATES[:seeking]
    ordered_questions.collect do |sq|
      state = STATES[:first_question_found] if sq.id == survey_question.id
      next if STATES[:seeking] == state
      state = STATES[:last_question_found] if !sq.note?
      next if STATES[:last_question_found] == state
      sq.note
    end.compact
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

  def max_z_index
    ordered_notes.map(&:z_index).compact.max || 0
  end

  def clean_up_notes_z_index
    ordered_notes.each_with_index do |note, i|
      note.update z_index: i+1
    end
  end

  # ------------------------------------------------------------------------
  ######
  # PREV
  #####
  def get_prev_page_start_question_id(survey_question)
    # | starting from the last question
    # |
    # V
    # question      <- skip
    # question      <- skip
    # question      <- current group/question position (skip)
    # new_page/note <- update question_position and start looking for next page/non-note
    # question/note <- update question_position
    # question/note <- update question_position
    # new_page      <- break if new_page or non-note
    question_id = -1
    state = STATES[:seeking]
    ordered_questions.reverse.each do |sq|
      case state
      when STATES[:seeking]
        next unless sq.id == survey_question.id
        state = sq.note? ? STATES[:first_page_found] : STATES[:current_position_found]
      when STATES[:current_position_found]
        # assumption: previous question will be a note or new_page
        state = STATES[:first_page_found] if sq.new_page?
        state = STATES[:seeking_non_note] if sq.note?
      when STATES[:seeking_non_note]
        # when dealing with a group of notes
        break if !sq.note?
        question_id = sq.id
      when STATES[:first_page_found]
        next if sq.new_page?
        question_id = sq.id
        state = STATES[:seeking_second_page]
      when STATES[:seeking_second_page]
        break if sq.new_page? || sq.note?
        question_id = sq.id
      end
    end
    question_id
  end

  # ------------------------------------------------------------------------
  ######
  # NEXT
  #####
  def get_next_page_start_question_id(survey_question)
    # question      <- update question_position and break
    # new_page/note <- update and break if note, skip if new_page
    # question      <- skip
    # question      <- skip
    # question      <- current question position (skip)
    # ^             <- skip all previous questions
    # |
    # | start from the first question
    question_id = -1
    state = STATES[:seeking]
    ordered_questions.each do |sq|
      case state
      when STATES[:seeking]
        next unless sq.id == survey_question.id
        state = sq.note? ? STATES[:seeking_non_note] : STATES[:current_position_found]
      when STATES[:current_position_found]
        state = STATES[:page_found] if sq.new_page?
        question_id = sq.id
        state = STATES[:finished] if sq.note?
      when STATES[:page_found]
        next if sq.new_page?
        question_id = sq.id
        state = STATES[:finished]
      when STATES[:seeking_non_note]
        question_id = sq.id
        state = STATES[:finished] if !sq.note?
      end
      return question_id if STATES[:finished] == state
    end
    -1
  end

  # ------------------------------------------------------------------------

  def self.import_sticky_notes_tsv
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
        row = 0
      end

      if row > 4
        column += 1
        row = 0
      end
      left = (225 * (column - 1 + new_survey_group.position - 1)) + 20
      top = (225 * row) + 130
      row += 1

      new_note = Operation::SurveyHelper::create_new_note({
        survey_group: new_survey_group,
        text: text,
        coords: "#{left}px:#{top}px"
      })
      raise "something went wrong with note creation" unless new_note
      new_position = new_survey_group.reload.survey_questions.count-1
      new_note.update position: new_position
      new_note.survey_question.update position: new_position
    end
    # move the feedback group to the end
    survey.survey_groups.where(name: "Feedback").first.update position: survey.survey_groups.count
    survey.fixup_positions
  end

  # ------------------------------------------------------------------------

  def self.import_sticky_notes_csv(filename)
    file = File.open "tmp/#{filename}.csv"
    data = file.readlines.map(&:chomp)
    file.close

    survey_name = "Survey for group #{filename}"
    survey = Survey.find_by_name(survey_name) ||
    Operation::SurveyHelper::create_new_survey({
      name: survey_name,
      description: "Voting survey",
      create_initial_questions: true
    })
    raise "something went wrong with survey creation / find" unless survey

    column = -1
    row = 0
    group = nil

    data.each do |line|
      # line.gsub!(/^"(.+)"$/, '\1')
      puts "line = #{group ? group.name : "no group"}: #{line}"
      if line.match /Vision/
        assign_max_votes(group)
        group = create_group(survey, "Instructions for Vision / Mission", "")
        question = create_question(group, {question_type: "New Page"})
        question = create_question(group, {
          question_type: "Instructions",
          question: "### Carefully consider the following Vision and Mission nuggets and vote on the ones you feel are most important.
---
#### When voting on these nuggets, ask these questions **from your felt perspective**:

- What supports an inspiring future in Emergent Commons?
- What would enable an impact in life?
- What energizes and motivates you to be in this community - choose nuggets that stir passion.
- Focus on what matters most - what are our core values and priorities?"
        })
        question = create_question(group, {
          question_type: "Instructions",
          question: "#### _INSTRUCTIONS_:

- Vision and Mission nuggets are on different colored sticky notes.
- You *may* have to scroll right to see the Mission notes
- Cast multiple tokens for any one nugget, up to a maximum number of tokens.
- The number of tokens you have left is shown under the up/down buttons."
        })
        group = create_group(survey, "Vision")
        column += 1
        row = 0
        next
      elsif line.match /Mission/
        assign_max_votes(group)
        group = create_group(survey, "Mission")
        column += 1
        row = 0
        next
      elsif line.match /Values/
        assign_max_votes(group)
        group = create_group(survey, "Instructions for Values", "")
        question = create_question(group, {
          question_type: "Instructions",
          question: "Now carefully consider the following values and vote on the ones that most resonate with you as important to the purpose of Emergent Commons."
        })
        group = create_group(survey, "Values")
        column = row = 0
        next
      elsif line.match /Uncategorized/
        assign_max_votes(group)
        break # finished
        group = create_group(survey, "Uncategorized")
        column += 1
        row = 0
        next
      end
      raise "something went wrong with group creation" unless group

      if row > 4
        column += 1
        row = 0
      end
      left = (225 * column) + 30
      top = (225 * row) + 130
      row += 1

      new_note = Operation::SurveyHelper::create_new_note({
        survey_group: group,
        text: line,
        coords: "#{left}px:#{top}px"
      })
      raise "something went wrong with note creation" unless new_note
      new_position = group.reload.survey_questions.count-1
      new_note.update position: new_position
      new_note.survey_question.update position: new_position
    end
    assign_max_votes(group)
    # move the feedback group to the end
    survey.survey_groups.where(name: "Feedback").first.update position: survey.survey_groups.count
    survey.fixup_positions
  end

  def self.create_question(group, params)
    Operation::SurveyHelper::create_new_survey_question({
      survey_group: group,
      question_type: params[:question_type],
      answer_type: params[:answer_type],
      question: params[:question],
      answer_labels: params[:answer_labels],
      has_scale: params[:has_scale],
      scale_question: params[:scale_question],
      scale_labels: params[:scale_labels]
    })
  end

  def self.create_group(survey, group_name, description=nil)
    puts "creating #{group_name} group..."
    Operation::SurveyHelper::create_new_survey_group({
      survey: survey,
      name: group_name,
      description: description || "change this description",
      votes_max: nil, # will be assigned based on algorithm below
      note_color: case group_name
      when "Vision"
        "#f7f7ad"
      when "Mission"
        "#c3edc0"
      when "Values"
        "#afdaea"
      else
        "#e7f2a4"
      end
    })
  end

  def self.assign_max_votes(group)
    return unless group
    notes_count = group.notes.count
    votes_max = case notes_count
    when 1..5
      3
    when 6..18
      (2 * notes_count / 3).to_i
    else
      12 # max of 12
    end
    group.update votes_max: votes_max
  end
end
