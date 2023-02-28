require 'test_helper'

class SurveyOperationTest < MiniTest::Spec

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {Survey} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        description = "this is my unique description"
        result = create_survey_with_result({
          name: random_survey_name, 
          description: description
        })

        assert result.success?
        survey = result[:model]
        assert_equal last_random_survey_name, survey.name
        assert_equal description, survey.description
      end
    end

    it "Creates {Survey} model with non-unique description" do
      DatabaseCleaner.cleaning do
        existing_survey = create_survey

        result = create_survey_with_result({
          name: random_survey_name, 
          description: existing_survey.description
        })

        assert result.success?
        survey = result[:model]
        assert_equal existing_survey.description, survey.description
      end
    end

    # ----------------
    # failing path tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = Survey::Operation::Create.call(params: {})
        assert !result.success?
      end
    end

    it "Fails with no name attribute" do
      DatabaseCleaner.cleaning do
        result = create_survey_with_result({
          name: ""
        })

        assert !result.success?
        assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
      end
    end

    it "Fails with blank description" do
      DatabaseCleaner.cleaning do
        existing_survey = create_survey

        result = create_survey_with_result({
          name: random_survey_name, 
          description: ""
        })

        assert !result.success?
        assert_equal(["description must be filled"], result["contract.default"].errors.full_messages_for(:description))
      end
    end
  end
end
