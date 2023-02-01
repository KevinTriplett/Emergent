require "test_helper"

class AdminSurveysTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with no surveys" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      get admin_surveys_path
      assert_response :success
      assert_not_nil assigns(:surveys)

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "No Existing Surveys"
    end
  end

  test "Admin page with surveys" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      get admin_surveys_path
      assert_response :success
      assert_not_nil assigns(:surveys)

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Existing Surveys"
      assert_select ".survey-name", existing_survey.name
      assert_select "a", "edit"
      assert_select "a", "questions"
      assert_select "a", "delete"
      assert_select "a", "New Survey"
    end
  end

  test "Admin new page for survey" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      get new_admin_survey_path
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "New Survey"
      assert_select '#survey_name'
      assert_select '#survey_description'
      assert_select "a", "Cancel"
    end
  end

  test "Admin edit page for survey" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      get edit_admin_survey_path(existing_survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Editing Survey"
      assert_select '#survey_name' do
        assert_select "[value=?]", existing_survey.name
      end
      assert_select '#survey_description' do
        assert_select "[value=?]", existing_survey.description
      end
      assert_select "a", "Cancel"
    end
  end
end