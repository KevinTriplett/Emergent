require "test_helper"

class AdminSurveysTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with no surveys" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
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
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      survey = create_survey
      get admin_surveys_path
      assert_response :success
      assert_not_nil assigns(:surveys)

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Existing Surveys"
      assert_select ".survey-name", survey.name
      assert_select "a[href=?]", edit_admin_survey_path(survey.id), text: "edit"
      assert_select "a[href=?]", admin_survey_path(survey.id), text: "questions"
      assert_select "a[href=?]", new_admin_survey_survey_invite_path(survey.id), text: "invite"
      assert_select "a[href=?]", admin_survey_test_path(survey.id), text: "test"
      assert_select "a[href=?]", admin_survey_notes_path(survey.id), text: "notes"
      assert_select "a[href=?]", admin_survey_path(survey.id), text: "del"
      assert_select "a[href=?]", admin_survey_duplicate_path(survey.id), text: "duplicate"
      assert_select "a[href=?]", new_admin_survey_path(create_initial_questions: true), text: "New Survey"
    end
  end

  test "Admin new page for survey" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      survey = create_survey
      get new_admin_survey_path
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "New Survey"
      assert_select '#survey_name'
      assert_select '#survey_description'
      assert_select "input[type='submit'][value=?]", "Create Survey"
      assert_select "a", "Cancel"
    end
  end

  test "Admin edit page for survey" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      survey = create_survey
      get edit_admin_survey_path(survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Editing Survey"
      assert_select "#survey_name[value=?]", survey.name
      assert_select "#survey_description[value=?]", survey.description
      assert_select "input[type='submit'][value=?]", "Update Survey"
      assert_select "a", "Cancel"
    end
  end
end