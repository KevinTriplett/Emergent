require 'test_helper'

class SurveyTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "gets the last note group" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      assert_equal "Category Name", survey.last_note_category

      note_1 = create_note(survey: survey, category: "this 1")
      assert_equal "this 1", survey.reload.last_note_category
      note_2 = create_note(survey: survey, category: "this 2")
      assert_equal "this 2", survey.reload.last_note_category
      note_3 = create_note(survey: survey, category: "this 3")
      assert_equal "this 3", survey.reload.last_note_category
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
      question_0_0 = create_survey_question(survey_group: group_0)
      question_0_1 = create_survey_question(survey_group: group_0, question_type: "New Page")
      question_0_2 = create_survey_question(survey_group: group_0)
      question_1_0 = create_survey_question(survey_group: group_1)
      question_1_1 = create_survey_question(survey_group: group_1, question_type: "New Page")
      question_1_2 = create_survey_question(survey_group: group_1)
      question_2_0 = create_survey_question(survey_group: group_2)
      question_2_1 = create_survey_question(survey_group: group_2, question_type: "New Page")
      question_2_2 = create_survey_question(survey_group: group_2)

      assert_equal [0, 0], survey.get_prev_page_start_positions(question_0_0)
      assert_equal [0, 0], survey.get_prev_page_start_positions(question_0_0)

      assert_equal [0, 0], survey.get_prev_page_start_positions(question_1_0)
      assert_equal [1, 2], survey.get_next_page_start_positions(question_1_0)

      assert_equal [1, 0], survey.get_prev_page_start_positions(question_2_0)
      assert_equal [2, 2], survey.get_next_page_start_positions(question_2_0)

      assert_equal [0, 0], survey.get_prev_page_start_positions(question_0_2)
      assert_equal [1, 0], survey.get_next_page_start_positions(question_0_2)

      assert_equal [1, 0], survey.get_prev_page_start_positions(question_1_2)
      assert_equal [2, 0], survey.get_next_page_start_positions(question_1_2)

      assert_equal [2, 0], survey.get_prev_page_start_positions(question_2_2)
      assert_equal [2, 0], survey.get_next_page_start_positions(question_2_2)
    end
  end
end