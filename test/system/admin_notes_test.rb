require "application_system_test_case"

class NotesTest < ApplicationSystemTestCase
  DatabaseCleaner.clean

  test "Regular user cannot create a survey note" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      visit admin_survey_notes_path(survey_id: survey.id)
      assert_current_path root_path
    end
  end

  test "Admin can access, add, change and delete survey notes" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      admin = login

      visit admin_survey_notes_path(survey_id: survey.id)
      assert_current_path admin_survey_notes_path(survey_id: survey.id)
      
      assert_selector "#notes-container .note", count: 0
      click_on "Add Note"

      within("#notes-container") do
        assert_selector ".note", count: 1
        find(".note button.delete").click
        assert_selector ".note", count: 0
      end

      click_on "Add Note"

      within("#notes-container") do
        assert_selector ".note", count: 1
        find(".note .note-text").click
        find(".note .note-text").send_keys([:command, "a"], "What is this?")
        sleep 1
        note = survey.notes.first
        assert_equal "What is this?", note.text

        find(".note .note-category").click
        find(".note .note-category").send_keys([:command, "a"], "Dogegory")
        sleep 1
        assert_equal "Dogegory", note.reload.category

        message = dismiss_prompt do
          find(".note button.delete").click
        end
        assert_equal "Are you sure you want to delete this note?", message
        sleep 1
        assert_equal note.id, survey.reload.notes.first.id

        accept_prompt do
          find(".note button.delete").click
        end
        sleep 1
        assert survey.reload.notes.empty?
      end
    end
  end
end
