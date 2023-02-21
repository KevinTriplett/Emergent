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

  it "reports whether or not it is the first question" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      survey_question_1 = create_survey_question(survey: survey)
      survey_question_2 = create_survey_question(survey: survey)
      survey_question_3 = create_survey_question(survey: survey)

      assert  survey_question_1.first_question?
      assert !survey_question_2.first_question?
      assert !survey_question_3.first_question?

      assert !survey_question_1.last_question?
      assert !survey_question_2.last_question?
      assert  survey_question_3.last_question?
    end
  end
end