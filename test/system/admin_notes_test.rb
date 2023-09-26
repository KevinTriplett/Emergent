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
      group_1 = create_survey_group(name: "Group 1")
      survey = group_1.survey
      group_2 = create_survey_group(survey: survey, name: "Group 2")
      admin = login(:surveyor)
      assert survey.reload.ordered_notes.empty?
      assert survey.survey_questions.empty?

      visit admin_survey_notes_path(survey.id)
      assert_current_path admin_survey_notes_path(survey.id)
      
      assert_selector "#notes-container .note", count: 0
      click_on "Add Note"
      sleep 1

      assert_equal 1, survey.reload.ordered_notes.count
      assert_equal 1, survey.survey_questions.count
      assert_equal survey.survey_questions.first.question, survey.reload.ordered_notes.first.text
      assert_equal survey.survey_questions.first.group_name, survey.ordered_notes.first.group_name
      note_1 = survey.ordered_notes.first
      assert_equal group_1.name, note_1.reload.group_name
      assert_equal "Click here to edit", note_1.text
      assert_equal group_1.name, note_1.reload.group_name
      assert_selector ".note .note-text", text: note_1.text
      assert_selector ".ui-selectmenu-text", text: group_1.name

      within("#notes-container") do
        assert_selector ".note", count: 1
        message = dismiss_prompt do
          find(".note button.delete").click
        end
        assert_equal "Are you sure you want to delete this note?", message
        assert_selector ".note", count: 1
        accept_prompt do
          find(".note button.delete").click
        end
        assert_selector ".note", count: 0
      end
      sleep 1
      assert survey.reload.ordered_notes.empty?
      assert survey.survey_questions.empty?

      click_on "Add Note"
      sleep 1
      assert_equal 1, survey.reload.ordered_notes.count
      assert_equal 1, survey.survey_questions.count

      within("#notes-container") do
        assert_selector ".note", count: 1
        find(".note .note-text").click
        find(".note .note-text").send_keys([:command, "a"], "What is this?")

        find(".note-group-name .ui-selectmenu-text").click
      end
      find(".ui-menu-item-wrapper", text: group_2.name, exact_text: true).click
      assert_selector "#notes-container .ui-selectmenu-text", text: group_2.name
      sleep 1
      note_1 = survey.ordered_notes.first
      assert_equal "What is this?", note_1.text
      assert_equal group_2.name, note_1.reload.group_name

      click_on "Add Note"
      sleep 1

      assert_equal 2, survey.reload.ordered_notes.count
      assert_equal 2, survey.survey_questions.count
      note_2 = survey.ordered_notes.first
      assert_equal group_2.name, note_1.reload.group_name
    end
  end
end
