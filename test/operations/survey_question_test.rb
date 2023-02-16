require 'test_helper'

class SurveyQuestionOperationTest < MiniTest::Spec

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {SurveyQuestion} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        question_type = "Question"
        question = "this is my question to you: who are you?"
        answer_type = "Yes/No"
        has_scale = "1"
        scale_question = "Scale question this is"
        scale_labels = "Hi/Lo"
        answer_labels = "Good/Bye"

        existing_survey = create_survey
        result = create_survey_question_with_result({
          survey: existing_survey,
          question_type: question_type,
          question: question,
          answer_type: answer_type,
          scale_question: scale_question,
          scale_labels: scale_labels,
          answer_labels: answer_labels,
          has_scale: has_scale
        })

        assert result.success?
        survey_question = result[:model]
        assert_equal question_type, survey_question.question_type
        assert_equal question, survey_question.question
        assert_equal answer_type, survey_question.answer_type
        assert survey_question.has_scale
        assert_equal scale_question, survey_question.scale_question
        assert_equal scale_labels, survey_question.scale_labels
        assert_equal answer_labels, survey_question.answer_labels
      end
    end

    it "initializes answer_type" do
      DatabaseCleaner.cleaning do
        existing_survey = create_survey
        result = create_survey_question_with_result({
          survey: existing_survey,
          question_type: "New Page"
        })
        assert result.success?
        survey_question_1 = result[:model]
        assert_equal "NA", survey_question_1.answer_type

        result = create_survey_question_with_result({
          survey: existing_survey,
          question_type: "Instructions"
        })
        assert result.success?
        survey_question_2 = result[:model]
        assert_equal "NA", survey_question_2.answer_type

        result = create_survey_question_with_result({
          survey: existing_survey,
          question_type: "Group Name"
        })
        assert result.success?
        survey_question_3 = result[:model]
        assert_equal "NA", survey_question_3.answer_type
        assert_nil survey_question_3.scale_labels
        assert_nil survey_question_3.answer_labels

        result = create_survey_question_with_result({
          survey: existing_survey,
          question_type: "Branch",
          scale_labels: "",
          answer_labels: ""
        })
        assert result.success?
        survey_question_4 = result[:model]
        assert_equal "NA", survey_question_4.answer_type
        assert_nil survey_question_4.scale_labels
        assert_nil survey_question_4.answer_labels

        survey_question_1.update question_type: "Question"
        survey_question_1.update answer_type: "Essay"
        result = SurveyQuestion::Operation::Update.call(
          params: {
            survey_question: {
              question_type: "New Page",
              question: survey_question_1.question,
              answer_type: survey_question_1.answer_type,
              has_scale: survey_question_1.has_scale ? "1" : "0",
              answer_labels: survey_question_1.answer_labels,
              scale_labels: survey_question_1.scale_labels,
              scale_question: survey_question_1.scale_question,
              position: survey_question_1.position
            },
            survey_id: existing_survey.id,
            id: survey_question_1.id
          }
        )
        assert result.success?
        survey_question_1 = result[:model]
        assert_equal "NA", survey_question_1.reload.answer_type

        survey_question_1.update question_type: "Question"
        survey_question_1.update answer_type: "Essay"
        result = SurveyQuestion::Operation::Update.call(
          params: {
            survey_question: {
              question_type: "New Page",
              question: survey_question_1.question,
              answer_type: survey_question_1.answer_type,
              has_scale: survey_question_1.has_scale ? "1" : "0",
              answer_labels: survey_question_1.answer_labels,
              scale_labels: survey_question_1.scale_labels,
              scale_question: survey_question_1.scale_question,
              position: survey_question_1.position
            },
            survey_id: existing_survey.id,
            id: survey_question_1.id
          }
        )
        assert result.success?
        survey_question_1 = result[:model]
        assert_equal "NA", survey_question_1.reload.answer_type

        survey_question_1.update question_type: "Question"
        survey_question_1.update answer_type: "Essay"
        result = SurveyQuestion::Operation::Update.call(
          params: {
            survey_question: {
              question_type: "New Page",
              question: survey_question_1.question,
              answer_type: survey_question_1.answer_type,
              has_scale: survey_question_1.has_scale ? "1" : "0",
              answer_labels: survey_question_1.answer_labels,
              scale_labels: survey_question_1.scale_labels,
              scale_question: survey_question_1.scale_question,
              position: survey_question_1.position
            },
            survey_id: existing_survey.id,
            id: survey_question_1.id
          }
        )
        assert result.success?
        survey_question_1 = result[:model]
        assert_equal "NA", survey_question_1.reload.answer_type

        survey_question_1.update question_type: "Question"
        survey_question_1.update answer_type: "Essay"
        result = SurveyQuestion::Operation::Update.call(
          params: {
            survey_question: {
              question_type: "New Page",
              question: survey_question_1.question,
              answer_type: survey_question_1.answer_type,
              has_scale: survey_question_1.has_scale ? "1" : "0",
              answer_labels: "",
              scale_labels: "",
              scale_question: survey_question_1.scale_question,
              position: survey_question_1.position
            },
            survey_id: existing_survey.id,
            id: survey_question_1.id
          }
        )
        assert result.success?
        survey_question_1 = result[:model]
        assert_equal "NA", survey_question_1.reload.answer_type
        assert_nil survey_question_1.scale_labels
        assert_nil survey_question_1.answer_labels
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
        result = create_survey_question_with_result(question_type: "Question")
        assert !result.success?
        assert_equal(["question must be filled", "question must be a string"], result["contract.default"].errors.full_messages_for(:question))

        result = create_survey_question_with_result(question_type: "Question", question: 0)
        assert !result.success?
        assert_equal(["question must be a string"], result["contract.default"].errors.full_messages_for(:question))

        result = create_survey_question_with_result(question_type: "New Page")
        assert result.success?
      end
    end
  end
end
