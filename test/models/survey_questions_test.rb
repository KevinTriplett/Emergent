require 'test_helper'

class SurveyQuestionsTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "has class-scope question_types array" do
    assert_equal [
      "Question",
      "Instructions",
      "New Page",
      "Group Name",
      "Branch"
    ], SurveyQuestion::QUESTION_TYPES
  end

  it "has class-scope ansswer_types array" do
    assert_equal [
      "Yes/No",
      "Multiple Choice",
      "Essay",
      "Rating",
      "Range",
      "Number",
      "Vote",
      "NA"
    ], SurveyQuestion::ANSWER_TYPES
  end

  it "delegates ordered_questions to survey_group" do
    DatabaseCleaner.cleaning do
      group = create_survey_group
      question_1 = create_survey_question(survey_group: group)
      question_2 = create_survey_question(survey_group: group)
      question_3 = create_survey_question(survey_group: group)
      survey_invite = create_survey_invite(survey: group.survey)

      assert_equal [question_1.id, question_2.id, question_3.id], group.ordered_questions.collect(&:id)
    end
  end

  it "pseudo-delegates group_position to survey_group" do
    DatabaseCleaner.cleaning do
      group = create_survey_group
      question = create_survey_question(survey_group: group)
      
      assert_equal question.group_position, group.position

      group.update(position: 5)
      assert_equal question.reload.group_position, group.position
    end
  end

  it "reports it is at the begining or ending of the group" do
    DatabaseCleaner.cleaning do
      group = create_survey_group
      question_1 = create_survey_question(survey_group: group)
      question_2 = create_survey_question(survey_group: group)
      question_3 = create_survey_question(survey_group: group)

      assert question_1.at_group_beginning?
      assert question_2.at_group_beginning?
      assert question_3.at_group_beginning?

      assert question_1.at_group_ending?
      assert question_2.at_group_ending?
      assert question_3.at_group_ending?

      question_2.update question_type: "New Page"

      assert  question_1.at_group_beginning?
      assert !question_3.at_group_beginning?

      assert !question_1.at_group_ending?
      assert  question_3.at_group_ending?
    end
  end

  it "reports it is at the begining and ending" do
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

      assert  question_0_0.at_beginning?
      assert !question_0_2.at_beginning?
      assert !question_1_0.at_beginning?
      assert !question_1_2.at_beginning?
      assert !question_2_0.at_beginning?
      assert !question_2_2.at_beginning?

      assert !question_0_0.at_ending?
      assert !question_0_2.at_ending?
      assert !question_1_0.at_ending?
      assert !question_1_2.at_ending?
      assert !question_2_0.at_ending?
      assert  question_2_2.at_ending?
    end
  end
end