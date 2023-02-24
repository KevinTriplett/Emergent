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
      create_note(survey: survey, survey_group: group_1)
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

  it "gives previous and next group and question" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey)
      group_2 = create_survey_group(survey: survey)
      group_3 = create_survey_group(survey: survey)
      question_0_0 = create_survey_question(survey_group: group_0)
      question_0_1 = create_survey_question(survey_group: group_0)
      question_0_2 = create_survey_question(survey_group: group_0, question_type: "New Page")
      question_0_3 = create_survey_question(survey_group: group_0, question_type: "New Page")
      question_0_4 = create_survey_question(survey_group: group_0)
      question_1_0 = create_survey_question(survey_group: group_1, question_type: "New Page")
      question_1_1 = create_survey_question(survey_group: group_1, question_type: "New Page")
      question_1_2 = create_survey_question(survey_group: group_1)
      question_1_3 = create_survey_question(survey_group: group_1)
      question_1_4 = create_survey_question(survey_group: group_1)
      question_2_0 = create_survey_question(survey_group: group_2)
      question_2_1 = create_survey_question(survey_group: group_2, question_type: "New Page")
      question_2_2 = create_survey_question(survey_group: group_2)
      question_2_3 = create_survey_question(survey_group: group_2, question_type: "New Page")
      question_2_4 = create_survey_question(survey_group: group_2, question_type: "New Page")
      question_3_0 = create_survey_question(survey_group: group_3)
      question_3_1 = create_survey_question(survey_group: group_3)
      question_3_2 = create_survey_question(survey_group: group_3, question_type: "New Page")
      question_3_3 = create_survey_question(survey_group: group_3, question_type: "New Page")
      question_3_4 = create_survey_question(survey_group: group_3)

      assert_equal [0,1,2,3,4], [question_0_0,question_0_1,question_0_2,question_0_3,question_0_4].map(&:position)
      assert_equal [0,1,2,3,4], [question_1_0,question_1_1,question_1_2,question_1_3,question_1_4].map(&:position)
      assert_equal [0,1,2,3,4], [question_2_0,question_2_1,question_2_2,question_2_3,question_2_4].map(&:position)
      assert_equal [0,1,2,3,4], [question_3_0,question_3_1,question_3_2,question_3_3,question_3_4].map(&:position)

      assert_equal [-1, -1], survey.get_prev_page_start_positions(question_0_0)
      assert_equal [0, 4], survey.get_next_page_start_positions(question_0_0)

      # TODO: test for this wacked condition
      # assert_equal [0, 4], survey.get_prev_page_start_positions(question_1_2)
      # assert_equal [2, 0], survey.get_next_page_start_positions(question_1_2)

      assert_equal [1, 2], survey.get_prev_page_start_positions(question_2_0)
      assert_equal [2, 2], survey.get_next_page_start_positions(question_2_0)

      assert_equal [2, 2], survey.get_prev_page_start_positions(question_3_0)
      assert_equal [3, 4], survey.get_next_page_start_positions(question_3_0)

      # TODO: test for this wacked condition
      # assert_equal [0, 0], survey.get_prev_page_start_positions(question_0_4)
      # assert_equal [1, 2], survey.get_next_page_start_positions(question_0_4)

      # there is no second set for group_1 questions

      # TODO: test for this wacked condition
      # assert_equal [2, 0], survey.get_prev_page_start_positions(question_2_2)
      # assert_equal [3, 0], survey.get_next_page_start_positions(question_2_2)

      assert_equal [3, 0], survey.get_prev_page_start_positions(question_3_4)
      assert_equal [-1, -1], survey.get_next_page_start_positions(question_3_4)
    end
  end
end