require 'test_helper'

class SurveyTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "has an ordered list of questions" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      question_1 = create_survey_question(survey: survey)
      question_2 = create_survey_question(survey: survey)
      question_3 = create_survey_question(survey: survey)

      assert_equal [question_1.id, question_2.id, question_3.id], survey.survey_questions.map(&:id)

      question_1.update position: 3
      question_2.update position: 2
      question_3.update position: 1
      assert_equal [question_1.id, question_2.id, question_3.id], survey.survey_questions.map(&:id)
      assert_equal [question_3.id, question_2.id, question_1.id], survey.ordered_questions.map(&:id)
    end
  end

  it "gets the last note category" do
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
end