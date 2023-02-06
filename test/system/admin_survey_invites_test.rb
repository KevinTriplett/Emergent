require "application_system_test_case"

class AdminSurveyInvitesTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "Admin can create a survey invite" do
    DatabaseCleaner.cleaning do
      admin = login
      existing_survey = create_survey
      existing_user = create_user(name: "Kevin Triplett")
      existing_user.update(first_name: "Kevin")
      existing_user.update(last_name: "Triplett")

      assert_nil SurveyInvite.first
      visit admin_surveys_path
      assert_current_path admin_surveys_path
      click_link "invite"

      assert_current_path new_admin_survey_survey_invite_path(survey_id: existing_survey.id)
      subject = "This are the subject"
      body = "This are the body"
      fill_in "Subject Line", with: subject
      fill_in "Invitation Text", with: body
      search_input = find("#user-search")
      search_input.click
      search_input.send_keys(existing_user.first_name)
      assert_selector "span.user-name", text: existing_user.name
      page.find("span.user-name").click
      click_on "Send Invite"

      assert_current_path admin_survey_survey_invites_path(survey_id: existing_survey.id)
      survey_invite = SurveyInvite.first
      assert survey_invite
      assert_equal existing_user.id, survey_invite.user_id
      assert_equal existing_survey.id, survey_invite.survey_id
      assert_equal subject, survey_invite.subject
      assert_equal body, survey_invite.body
      assert_nil survey_invite.sent_timestamp
      assert survey_invite.token
    end
  end
end
