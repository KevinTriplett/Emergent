require 'test_helper'

class NoteOperationTest < MiniTest::Spec

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {Note} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        group = create_survey_group
        text = "what is this text?"
        coords = "1234:4321"
        result = create_note_with_result({
          survey_group_id: group.id,
          text: text,
          coords: coords
        })

        assert result.success?
        note = result[:model]
        assert_equal group.name, note.group_name
        assert_equal text, note.text
        assert_equal coords, note.coords
        assert_equal 0, note.position
      end
    end

    it "Defaults note_color to group color or #FFFF99" do
      DatabaseCleaner.cleaning do
        group = create_survey_group(note_color: "#123456")
        assert_equal "#123456", group.note_color

        note = create_note(survey_group: group)
        assert_equal group.note_color, note.color

        group.update note_color: nil
        note = create_note(survey_group: group)
        assert_equal "#FFFF99", note.color
      end
    end

    # ----------------
    # failing path tests
    it "Fails with no text attribute" do
      DatabaseCleaner.cleaning do
        group = create_survey_group
        result = create_note_with_result({
          text: "",
          survey_group_id: group.id
        })

        assert !result.success?
        assert_equal(["text must be filled"], result["contract.default"].errors.full_messages_for(:text))
      end
    end
  end
end
