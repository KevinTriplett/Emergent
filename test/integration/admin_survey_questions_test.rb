require "test_helper"

class AdminSurveyQuestionsTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with surveys but no questions" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      get admin_survey_path(existing_survey.id)

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Editing Survey Questions"
      assert_select "p.survey-name", "Survey: #{existing_survey.name}"
      assert_select "a", {count: 0, text: "edit"}
      assert_select "a", {count: 0, text: "delete"}
      assert_select "a.btn", "New Question"
    end
  end

  test "Admin page for survey with question" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      existing_survey_question = create_survey_question({survey: existing_survey})
      get admin_survey_path(existing_survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Editing Survey Questions"
      assert_select "p.survey-name", "Survey: #{existing_survey.name}"
      assert_select "tr[data-url=?]", admin_survey_question_patch_url(existing_survey_question.id)
      assert_select "tr[data-id=?]", existing_survey_question.id.to_s
      assert_select "tr[data-position=?]", existing_survey_question.position.to_s
      assert_select "td.question-type", existing_survey_question.question_type
      assert_select "td.question", existing_survey_question.question
      assert_select "td.answer-type", existing_survey_question.answer_type
      assert_select "td.has-scale", existing_survey_question.has_scale? ? "Yes" : "No"
      assert_select "a", "edit"
      assert_select "a", "delete"
      assert_select "a", "New Question"
      assert_select "a", "Back"
      assert_select "a[href=?]", admin_surveys_path
    end
  end

  test "Admin create page for survey question" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      get new_admin_survey_survey_question_path(survey_id: existing_survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "New Survey Question"
      assert_select '#survey_question_question_type'
      assert_select '#survey_question_answer_type'
      assert_select '#survey_question_question'
      assert_select "#survey_question_has_scale"
      assert_select "#survey_question_has_scale[checked]", false
      assert_select "input[type=submit]"
      assert_select "a", "Cancel"
    end
  end

  test "Admin edit page for survey question" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      existing_survey_question = create_survey_question(survey: existing_survey)
      get edit_admin_survey_survey_question_path(existing_survey_question.id, survey_id: existing_survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Editing Survey Question"
      assert_select '#survey_question_question_type' do
        assert_select "[value=?]", existing_survey_question.question_type
      end
      assert_select '#survey_question_answer_type' do
        assert_select "[value=?]", existing_survey_question.answer_type
      end
      assert_select '#survey_question_question' do
        assert_select "[value=?]", existing_survey_question.question
      end
      assert_select "#survey_question_has_scale[checked]", false
      assert_select "a", "Cancel"

      existing_survey_question.update(has_scale: true)
      get edit_admin_survey_survey_question_path(existing_survey_question.id, survey_id: existing_survey.id)
      assert_select "#survey_question_has_scale[checked]", true
    end
  end
end