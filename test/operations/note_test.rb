require 'test_helper'

class NoteOperationTest < MiniTest::Spec

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {Note} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        category = "what a category"
        text = "what is this text?"
        color = "#000000"
        coords = "1234:4321"
        result = create_note_with_result({
          category: category, 
          text: text,
          color: color,
          coords: coords
        })

        assert result.success?
        note = result[:model]
        assert_equal category, note.category
        assert_equal text, note.text
        assert_equal color, note.color
        assert_equal coords, note.coords
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
          text: ""
        })

        assert !result.success?
        assert_equal(["text must be filled"], result["contract.default"].errors.full_messages_for(:text))
      end
    end

    it "Fails with no category attribute" do
      DatabaseCleaner.cleaning do
        result = create_note_with_result({
          category: ""
        })

        assert !result.success?
        assert_equal(["category must be filled"], result["contract.default"].errors.full_messages_for(:category))
      end
    end
  end
end
