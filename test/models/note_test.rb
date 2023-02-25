require 'test_helper'

class NoteTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "sets and gets survey_group name" do
    DatabaseCleaner.cleaning do
      note = create_note
      group_1 = note.survey_group
      survey = group_1.survey
      assert_equal group_1.name, note.group_name

      group_2 = create_survey_group(survey: survey)
      note.group_name = group_2.name
      assert_equal group_2.id, note.survey_group_id
    end
  end
end