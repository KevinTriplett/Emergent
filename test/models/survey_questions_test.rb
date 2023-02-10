require 'test_helper'

class SurveyQuestionsTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "has class-scope question_types array" do
    assert_equal [
      "Question",
      "Instructions",
      "New Page",
      "Branch"
    ], SurveyQuestion::QUESTION_TYPES
  end

  it "has class-scope ansswer_types array" do
    assert_equal [
      "Yes/No",
      "Multiple Choice",
      "Essay",
      "Rating",
      "Number",
      "NA"
    ], SurveyQuestion::ANSWER_TYPES
  end
end
    
