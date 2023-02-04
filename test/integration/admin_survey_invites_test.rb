require "test_helper"

class AdminSurveyInvitesTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page to choose survey to invite" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      get admin_surveys_path
      assert_response :success

      assert_select "p.survey a[href=?]", new_admin_survey_survey_invite_path(survey_id: existing_survey.id)
    end
  end

  test "Admin page for choosing users for survey invite" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      existing_survey = create_survey
      get new_admin_survey_survey_invite_path(survey_id: existing_survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Create Survey Invitation"
      assert_select "input#survey_survey_invite_", "Create Survey Invitation"
    end
  end
end