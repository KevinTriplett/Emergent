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

    it "Creates initial group and questions" do
      DatabaseCleaner.cleaning do
        result = create_survey_with_result({
          name: random_survey_name,
          description: "This is the survey description",
          create_initial_questions: true
        })

        assert result.success?
        survey = result[:model]
        assert_equal 1, survey.survey_groups.count
        assert_equal 3, survey.survey_questions.count
        assert_equal "Multiple Choice", survey.ordered_questions[0].answer_type
        assert_equal "Email", survey.ordered_questions[1].answer_type
        assert_equal "New Page", survey.ordered_questions[2].question_type
      end
    end

    it "Can duplicate an existing survey" do
      DatabaseCleaner.cleaning do
        existing_survey = create_survey(create_initial_questions: true)
        note_group = create_survey_group(survey: existing_survey)
        note = create_note(survey_group: note_group)

        result = Survey::Operation::Duplicate.call( params: { id: existing_survey.id } )
        assert result.success?

        new_survey = result[:model]
        new_survey.survey_groups.each do |group|
          assert existing_survey.survey_groups.where(name: group.name).first
        end
        new_survey.survey_questions.each do |question|
          assert existing_survey.survey_questions.where(question: question.question).first
        end
        new_survey.notes.each do |note|
          assert existing_survey.notes.where(text: note.text).first
        end
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
