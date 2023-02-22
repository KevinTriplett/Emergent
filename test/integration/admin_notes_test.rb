require "test_helper"

class AdminNotesTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page for survey notes but no notes" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      survey = create_survey
      get admin_survey_notes_path(survey.id)

      assert_select "h1", "Emergent Commons Jamboard"
      assert_select "h5", "Notes for #{survey.name}"
      assert_select "button.add", count: 1
      assert_select "#notes-container .note", count: 0
      assert_select "#note-template.hidden .note", count: 1
    end
  end

  test "Admin page for survey notes with notes" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      survey = create_survey
      text = "What's all this then?"
      category = "dogatory"
      color = "#123456"
      note = create_note({
        survey: survey,
        text: text,
        category: category,
        color: color
      })
      get admin_survey_notes_path(survey.id)

      assert_select "h1", "Emergent Commons Jamboard"
      assert_select "h5", "Notes for #{survey.name}"
      assert_select "button.add", count: 1
      assert_select "#notes-container .note", count: 1
      assert_select "#notes-container .note .note-text", text
      assert_select "#notes-container .note .note-category", category
      assert_select "#notes-container .note[style='background-color: #{color};']", count: 1
      assert_select "#note-template.hidden .note", count: 1
    end
  end
end