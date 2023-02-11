require 'test_helper'

class SurveyAnswerOperationTest < MiniTest::Spec

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {SurveyAnswer} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        answer = "this is my answer to you: who are you?"
        scale = 25
        existing_survey = create_survey
        existing_user = create_user

        result = create_survey_answer_with_result({
          survey: existing_survey,
          user: existing_user,
          answer: answer,
          scale: scale
        })

        assert result.success?
        survey_answer = result[:model]
        assert_equal answer, survey_answer.answer
        assert_equal scale, survey_answer.scale
      end
    end

    it "Creates {SurveyAnswer} model when no scale attribute given" do
      DatabaseCleaner.cleaning do
        result = create_survey_answer_with_result({
          answer: "this is an answer",
          scale: ""
        })

        assert result.success?
        survey_answer = result[:model]
        assert_nil survey_answer.scale
      end
    end

    # ----------------
    # failing path tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = SurveyAnswer::Operation::Create.call(params: {})
        assert !result.success?
      end
    end

    it "Fails with no answer attribute" do
      DatabaseCleaner.cleaning do
        result = create_survey_answer_with_result({answer: nil})
        assert !result.success?
        assert_equal(["answer must be filled"], result["contract.default"].errors.full_messages_for(:answer))

        result = create_survey_answer_with_result({answer: 0})
        assert !result.success?
        assert_equal(["answer must be a string"], result["contract.default"].errors.full_messages_for(:answer))
      end
    end

    it "Fails with no scale attribute and question has scale" do
      DatabaseCleaner.cleaning do
        existing_survey_question = create_survey_question({has_scale: true})
        result = create_survey_answer_with_result({
          answer: "this is an answer",
          survey_question: existing_survey_question
        })
        assert !result.success?
        assert_equal(["scale must be an integer"], result["contract.default"].errors.full_messages_for(:scale))
        
        result = create_survey_answer_with_result({
          scale: "",
          answer: "this is an answer",
          survey_question: existing_survey_question
        })
        assert !result.success?
        assert_equal(["scale must be an integer"], result["contract.default"].errors.full_messages_for(:scale))
      end
    end
  end
end
