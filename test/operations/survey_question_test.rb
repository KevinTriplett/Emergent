require 'test_helper'

class SurveyQuestionOperationTest < MiniTest::Spec

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {SurveyQuestion} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        question_type = "challenge"
        question = "this is my question to you: who are you?"
        answer_type = "truth or dare"
        has_scale = false
        existing_survey = create_survey

        result = create_survey_question_with_result({
          survey: existing_survey,
          question_type: question_type,
          question: question,
          answer_type: answer_type,
          has_scale: has_scale
        })

        assert result.success?
        survey_question = result[:model]
        assert_equal question_type, survey_question.question_type
        assert_equal question, survey_question.question
        assert_equal answer_type, survey_question.answer_type
        assert_equal has_scale, survey_question.has_scale
      end
    end

    it "Creates {SurveyQuestion} model with next question order" do
      DatabaseCleaner.cleaning do
        existing_survey = create_survey
        existing_question_1 = create_survey_question(survey: existing_survey)
        assert_equal 0, existing_question_1.position
        existing_question_2 = create_survey_question(survey: existing_survey)
        assert_equal 1, existing_question_2.position
      end
    end

    it "Updates {SurveyQuestion} with new order" do
      DatabaseCleaner.cleaning do
        existing_survey = create_survey
        existing_question = create_survey_question(survey: existing_survey)
        new_position = existing_question.position + 1
        model_hash = {
          model: {
            position: new_position
          },
          id: existing_question.id
        }
        result = SurveyQuestion::Operation::Patch.call(params: model_hash)
        assert result.success?
        assert_equal new_position, existing_question.reload.position
      end
    end

    # ----------------
    # failing path tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = SurveyQuestion::Operation::Create.call(params: {})
        assert !result.success?
      end
    end

    it "Fails with no or bad question_type attribute" do
      DatabaseCleaner.cleaning do
        result = create_survey_question_with_result({question_type: nil})
        assert !result.success?
        assert_equal(["question_type must be filled"], result["contract.default"].errors.full_messages_for(:question_type))

        result = create_survey_question_with_result({question_type: 0})
        assert !result.success?
        assert_equal(["question_type must be a string"], result["contract.default"].errors.full_messages_for(:question_type))
      end
    end

    it "Fails with no and bad question attribute" do
      DatabaseCleaner.cleaning do
        result = create_survey_question_with_result({question: nil})
        assert !result.success?
        assert_equal(["question must be filled"], result["contract.default"].errors.full_messages_for(:question))

        result = create_survey_question_with_result({question: 0})
        assert !result.success?
        assert_equal(["question must be a string"], result["contract.default"].errors.full_messages_for(:question))
      end
    end

    it "Fails with no and bad answer_type attribute" do
      DatabaseCleaner.cleaning do
        result = create_survey_question_with_result({answer_type: nil})
        assert !result.success?
        assert_equal(["answer_type must be filled"], result["contract.default"].errors.full_messages_for(:answer_type))

        result = create_survey_question_with_result({answer_type: 0})
        assert !result.success?
        assert_equal(["answer_type must be a string"], result["contract.default"].errors.full_messages_for(:answer_type))
      end
    end
  end
end
