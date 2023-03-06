require 'test_helper'

class SurveyTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "gets the last note survey group" do
    DatabaseCleaner.cleaning do
      group_1 = create_survey_group
      survey = group_1.survey
      assert_equal group_1.name, survey.last_note_survey_group.name
      group_2 = create_survey_group(survey: survey)
      assert_equal group_1.name, survey.last_note_survey_group.name

      create_note(survey: survey, survey_group: group_2)
      assert_equal group_2.name, survey.reload.last_note_survey_group.name
      note = create_note(survey: survey, survey_group: group_2)
      note.group_name = group_1.name
      note.save
      assert_equal group_1.name, survey.reload.last_note_survey_group.name
    end
  end

  it "gives an ordered list of groups" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      group_1 = create_survey_group(survey: survey)
      group_2 = create_survey_group(survey: survey)
      group_3 = create_survey_group(survey: survey)

      assert_equal [group_1.id, group_2.id, group_3.id], survey.survey_groups.map(&:id)
      assert_equal [group_1.id, group_2.id, group_3.id], survey.ordered_groups.map(&:id)

      group_1.update position: 3
      group_2.update position: 2
      group_3.update position: 1
      assert_equal [group_1.id, group_2.id, group_3.id], survey.survey_groups.map(&:id)
      assert_equal [group_3.id, group_2.id, group_1.id], survey.ordered_groups.map(&:id)
    end
  end

  it "reports if there is a notes question_type in this survey_question's group" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      group_1 = create_survey_group(survey: survey, name: "1")
      group_2 = create_survey_group(survey: survey, name: "2")
      group_3 = create_survey_group(survey: survey, name: "3")
      question_1 = create_survey_question(survey_group: group_1, question: "1", question_type: "Question")
      question_2 = create_survey_question(survey_group: group_1, question: "2", question_type: "New Page")
      question_3 = create_survey_question(survey_group: group_1, question: "3", question_type: "Question")
      question_4 = create_survey_question(survey_group: group_2, question: "4", question_type: "Note")
      question_5 = create_survey_question(survey_group: group_2, question: "5", question_type: "Note")
      question_6 = create_survey_question(survey_group: group_3, question: "6", question_type: "Question")
      question_7 = create_survey_question(survey_group: group_3, question: "7", question_type: "Question")

      assert !survey.notes_next?(question_1)
      assert  survey.notes_next?(question_3)
      assert !survey.notes_next?(question_6)
      assert !survey.notes_next?(question_7)

      assert !survey.notes_prev?(question_1)
      assert !survey.notes_prev?(question_3)
      assert  survey.notes_prev?(question_6)
      assert  survey.notes_prev?(question_7)

      SurveyQuestion.order(created_at: :asc).each_with_index do |sq, i|
        sq.survey_group_id = group_1.id
        sq.position = i
        sq.save
      end

      assert !survey.notes_next?(question_1.reload)
      assert  survey.notes_next?(question_3.reload)
      assert !survey.notes_next?(question_6.reload)
      assert !survey.notes_next?(question_7.reload)

      assert !survey.notes_prev?(question_1)
      assert !survey.notes_prev?(question_3)
      assert  survey.notes_prev?(question_6)
      assert  survey.notes_prev?(question_7)
    end
  end

  it "gives previous and next group and question" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey)
      group_2 = create_survey_group(survey: survey)
      group_3 = create_survey_group(survey: survey)
      group_4 = create_survey_group(survey: survey)
      question_0_0 = create_survey_question(survey_group: group_0)
      question_0_1 = create_survey_question(survey_group: group_0)
      question_0_2 = create_survey_question(survey_group: group_0, question_type: "New Page")
      question_0_3 = create_survey_question(survey_group: group_0, question_type: "New Page")
      question_0_4 = create_survey_question(survey_group: group_0)
      question_1_0 = create_survey_question(survey_group: group_1, question_type: "New Page")
      question_1_1 = create_survey_question(survey_group: group_1)
      question_1_2 = create_survey_question(survey_group: group_1)
      question_1_3 = create_survey_question(survey_group: group_1)
      question_1_4 = create_survey_question(survey_group: group_1)
      question_2_0 = create_survey_question(survey_group: group_2)
      question_2_1 = create_survey_question(survey_group: group_2, question_type: "New Page")
      question_2_2 = create_survey_question(survey_group: group_2)
      question_2_3 = create_survey_question(survey_group: group_2)
      question_2_4 = create_survey_question(survey_group: group_2, question_type: "New Page")
      question_3_0 = create_survey_question(survey_group: group_3)
      question_3_1 = create_survey_question(survey_group: group_3)
      question_3_2 = create_survey_question(survey_group: group_3, question_type: "New Page")
      question_3_3 = create_survey_question(survey_group: group_3, question_type: "New Page")
      question_3_4 = create_survey_question(survey_group: group_3)
      question_4_0 = create_survey_question(survey_group: group_4)
      question_4_1 = create_survey_question(survey_group: group_4, question_type: "Note")
      question_4_2 = create_survey_question(survey_group: group_4, question_type: "Note")
      question_4_3 = create_survey_question(survey_group: group_4)
      question_4_4 = create_survey_question(survey_group: group_4)

      assert_equal [0,1,2,3,4], [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:position)
      assert_equal [0,1,2,3,4], [question_1_0,question_1_1,question_1_2,question_1_3,question_1_4].map(&:position)
      assert_equal [0,1,2,3,4], [question_2_0,question_2_1,question_2_2,question_2_3,question_2_4].map(&:position)
      assert_equal [0,1,2,3,4], [question_3_0,question_3_1,question_3_2,question_3_3,question_3_4].map(&:position)
      assert_equal [0,1,2,3,4], [question_4_0,question_4_1,question_4_2,question_4_3,question_4_4].map(&:position)

      # -----------------------------------------------------------------
      
      assert_equal [-1, -1], survey.get_prev_page_start_positions(question_0_0)
      assert_equal [0, 4], survey.get_next_page_start_positions(question_0_0)

      assert_equal [0, 4], survey.get_prev_page_start_positions(question_1_1)
      assert_equal [2, 2], survey.get_next_page_start_positions(question_1_1)
      
      assert_equal [0, 4], survey.get_prev_page_start_positions(question_2_0)
      assert_equal [2, 2], survey.get_next_page_start_positions(question_2_0)

      assert_equal [2, 2], survey.get_prev_page_start_positions(question_3_0)
      assert_equal [3, 4], survey.get_next_page_start_positions(question_3_0)

      assert_equal [3, 0], survey.get_prev_page_start_positions(question_4_0)
      assert_equal [4, 3], survey.get_next_page_start_positions(question_4_0)

      # -----------------------------------------------------------------

      assert_equal [3, 4], survey.get_prev_page_start_positions_before_notes
      assert_equal [4, 3], survey.get_next_page_start_positions_after_notes

      # -----------------------------------------------------------------

      assert_equal [0, 0], survey.get_prev_page_start_positions(question_0_4)
      assert_equal [1, 1], survey.get_next_page_start_positions(question_0_4)

      # NB: there is no second set of questions for group_1 questions

      assert_equal [1, 1], survey.get_prev_page_start_positions(question_2_2)
      assert_equal [3, 0], survey.get_next_page_start_positions(question_2_2)

      assert_equal [3, 0], survey.get_prev_page_start_positions(question_3_4)
      assert_equal [4, 3], survey.get_next_page_start_positions(question_3_4)

      assert_equal [3, 4], survey.get_prev_page_start_positions(question_4_3)
      assert_equal [-1, -1], survey.get_next_page_start_positions(question_4_3)
    end
  end

  it "gets all notes and fixes gaps in note and question positions" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey)
      question_0_0 = create_survey_question(survey_group: group_0)
      question_0_1 = create_survey_question(survey_group: group_0)
      question_0_2 = create_survey_question(survey_group: group_0)
      note_0_0 = create_note(survey_group: group_0)
      note_0_1 = create_note(survey_group: group_0)
      question_0_3 = note_0_0.survey_question
      question_0_4 = note_0_1.survey_question
      note_1_0 = create_note(survey_group: group_1)
      note_1_1 = create_note(survey_group: group_1)
      question_1_0 = note_1_0.survey_question
      question_1_1 = note_1_1.survey_question
      question_1_2 = create_survey_question(survey_group: group_1)
      question_1_3 = create_survey_question(survey_group: group_1)
      question_1_4 = create_survey_question(survey_group: group_1)

      assert_equal [0,1,2,3,4], [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:position)
      assert_equal [0,1,2,3,4], [question_1_0,question_1_1,question_1_2,question_1_3,question_1_4].map(&:position)
      assert_equal [0,1], [note_0_0,note_0_1].map(&:position)
      assert_equal [0,1], [note_1_0,note_1_1].map(&:position)
      assert_equal [0,0,0,0,0], [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:group_position)
      assert_equal [1,1,1,1,1], [question_1_0,question_1_1,question_1_2,question_1_3,question_1_4].map(&:group_position)
      assert_equal [0,0], [note_0_0,note_0_1].map(&:group_position)
      assert_equal [1,1], [note_1_0,note_1_1].map(&:group_position)

      questions = [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4,question_1_0,question_1_1,question_1_2,question_1_3,question_1_4].map(&:id)
      notes = [note_0_0,note_0_1,note_1_0,note_1_1].map(&:id)
      assert_equal questions, survey.ordered_questions.map(&:id)
      assert_equal notes, survey.ordered_notes.map(&:id)

      note_0_0.group_name = group_1.name
      note_0_0.save
      [note_0_0,note_0_1,note_1_0,note_1_1].each(&:reload)
      
      assert_equal [2,1], [note_0_0,note_0_1].map(&:position)
      assert_equal [0,1], [note_1_0,note_1_1].map(&:position)
      assert_equal [1,0], [note_0_0,note_0_1].map(&:group_position)
      assert_equal [1,1], [note_1_0,note_1_1].map(&:group_position)
      
      survey.fixup_positions
      [note_0_0,note_0_1,note_1_0,note_1_1].each(&:reload)
      assert_equal [2,0], [note_0_0,note_0_1].map(&:position)
      assert_equal [0,1], [note_1_0,note_1_1].map(&:position)
      assert_equal [1,0], [note_0_0,note_0_1].map(&:group_position)
      assert_equal [1,1], [note_1_0,note_1_1].map(&:group_position)

      note_1_0.destroy
      
      survey.reload.fixup_positions
      [note_0_0,note_0_1,note_1_1].each(&:reload)
      assert_equal [1,0], [note_0_0,note_0_1].map(&:position)
      assert_equal [0], [note_1_1].map(&:position)
      assert_equal [1,0], [note_0_0,note_0_1].map(&:group_position)
      assert_equal [1], [note_1_1].map(&:group_position)

      question_1_3.group_name = group_0.name
      question_1_3.save
      [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].each(&:reload)
      [question_1_1,question_1_2,question_1_3,question_1_4].each(&:reload)
      
      assert_equal [0,1,2,3,4], [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:position)
      assert_equal [0,1,5,3], [question_1_1,question_1_2,question_1_3,question_1_4].map(&:position)
      assert_equal [0,0,0,0,0], [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:group_position)
      assert_equal [1,1,0,1], [question_1_1,question_1_2,question_1_3,question_1_4].map(&:group_position)

      survey.fixup_positions
      [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:reload)
      [question_1_1,question_1_2,question_1_3,question_1_4].map(&:reload)
      assert_equal [0,1,2,3,4], [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:position)
      assert_equal [0,1,5,2], [question_1_1,question_1_2,question_1_3,question_1_4].map(&:position)
      assert_equal [0,0,0,0,0], [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:group_position)
      assert_equal [1,1,0,1], [question_1_1,question_1_2,question_1_3,question_1_4].map(&:group_position)

      question_0_2.destroy

      survey.fixup_positions
      [question_0_0,question_0_1,question_0_3,question_0_4].map(&:reload)
      [question_1_1,question_1_2,question_1_3,question_1_4].map(&:reload)
      assert_equal [0,1,2,3], [question_0_0,question_0_1,question_0_3,question_0_4].map(&:position)
      assert_equal [0,1,4,2], [question_1_1,question_1_2,question_1_3,question_1_4].map(&:position)
      assert_equal [0,0,0,0], [question_0_0,question_0_1,question_0_3,question_0_4].map(&:group_position)
      assert_equal [1,1,0,1], [question_1_1,question_1_2,question_1_3,question_1_4].map(&:group_position)
    end
  end

  it "selects survey_questions based on first question in page" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey)
      question_0_0 = create_survey_question(survey_group: group_0)
      question_0_1 = create_survey_question(survey_group: group_0, question_type: "New Page")
      question_0_2 = create_survey_question(survey_group: group_0)
      question_0_3 = create_survey_question(survey_group: group_0)
      note_0_0 = create_note(survey_group: group_0)
      question_0_4 = note_0_0.survey_question
      note_1_0 = create_note(survey_group: group_1)
      question_1_0 = note_1_0.survey_question
      question_1_1 = create_survey_question(survey_group: group_1)
      question_1_2 = create_survey_question(survey_group: group_1)
      question_1_3 = create_survey_question(survey_group: group_1, question_type: "New Page")
      question_1_4 = create_survey_question(survey_group: group_1)

      assert_equal [question_0_0].map(&:id).to_set, survey.get_survey_questions(question_0_0).map(&:id).to_set
      assert_equal [question_0_2,question_0_3].map(&:id).to_set, survey.get_survey_questions(question_0_2).map(&:id).to_set
      assert_equal [question_1_1,question_1_2].map(&:id).to_set, survey.get_survey_questions(question_1_1).map(&:id).to_set
      assert_equal [question_1_4].map(&:id).to_set, survey.get_survey_questions(question_1_4).map(&:id).to_set
    end
  end
end