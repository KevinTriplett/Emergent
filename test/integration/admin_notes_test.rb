require "test_helper"

class AdminNotesTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page for survey notes but no notes" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      survey = create_survey
      get admin_survey_notes_path(survey.id)

      assert_select "h1", "Emergent Commons Jamboard"
      assert_select "h5", "Notes for #{survey.name}"
      assert_select "a.add-note", count: 1
      assert_select "a.return", count: 1
      assert_select "a.new-group", count: 1
      assert_select "#notes-container .note", count: 0
    end
  end

  test "Admin page for survey notes with notes" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      group = create_survey_group(color: "#123456")
      survey = group.survey
      text = "What's all this then?"
      note = create_note({
        survey_group_id: group.id,
        text: text
      })
      get admin_survey_notes_path(survey.id)

      assert_select "h1", "Emergent Commons Jamboard"
      assert_select "h5", "Notes for #{survey.name}"
      assert_select "a.add-note", count: 1
      assert_select "a.return", count: 1
      assert_select "a.new-group", count: 1
      assert_select "#notes-container .note", count: 1
      assert_select "#notes-container .note .note-text", text
      assert_select "#notes-container .note .note-group-name", group.name
    end
  end
end