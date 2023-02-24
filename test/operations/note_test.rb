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
        color = "#000000"
        coords = "1234:4321"
        result = create_note_with_result({
          survey_group_id: group.id,
          text: text,
          color: color,
          coords: coords
        })

        assert result.success?
        note = result[:model]
        assert_equal group.name, note.group_name
        assert_equal text, note.text
        assert_equal color, note.color
        assert_equal coords, note.coords
        assert_equal 0, note.position
      end
    end

    # ----------------
    # failing path tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = Note::Operation::Create.call(params: {})
        assert !result.success?
      end
    end

    it "Fails with no text attribute" do
      DatabaseCleaner.cleaning do
        result = create_note_with_result({
          text: "",
          survey_group_id: 0
        })

        assert !result.success?
        assert_equal(["text must be filled"], result["contract.default"].errors.full_messages_for(:text))
      end
    end

    it "Fails with no survey_group attribute" do
      DatabaseCleaner.cleaning do
        result = create_note_with_result({
          survey_group_id: ""
        })

        assert !result.success?
        assert_equal(["survey_group_id must be filled"], result["contract.default"].errors.full_messages_for(:survey_group_id))
      end
    end
  end
end
