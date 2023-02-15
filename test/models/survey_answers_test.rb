require 'test_helper'

class SurveyAnswersTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "delegates survey attributes" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      user = create_user
      survey_invite = create_survey_invite({
        survey: survey,
        user: user
      })
      survey_question = create_survey_question(survey: survey)
      survey_answer = create_survey_answer({
        survey_invite: survey_invite,
        survey_question_id: survey_question.id
      })

      assert_equal user.id, survey_answer.user.id
      assert_equal survey.id, survey_answer.survey.id
    end
  end

  it "delegates survey_question attributes" do
    DatabaseCleaner.cleaning do
      survey_question = create_survey_question
      survey_answer = create_survey_answer(survey_question_id: survey_question.id)

      assert_equal survey_question.question_type, survey_answer.question_type
      assert_equal survey_question.question, survey_answer.question
      assert_equal survey_question.has_scale?, survey_answer.has_scale?
      assert_equal survey_question.answer_type, survey_answer.answer_type
    end
  end
end
    
