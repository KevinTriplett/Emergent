require 'test_helper'

class NoteTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "sets and gets survey_group name" do
    DatabaseCleaner.cleaning do
      group_1 = create_survey_group
      survey = group_1.survey
      group_2 = create_survey_group(survey: survey)
      group_3 = create_survey_group
      note = create_note(survey_group: group_1)
      
      assert_equal group_1.name, note.group_name
      
      note.group_name = group_2.name
      assert_equal group_2.name, note.group_name
      assert_equal group_1.name, note.reload.group_name
      
      note.group_name = group_3.name # group_3 is not linked to survey
      assert_equal group_1.name, note.reload.group_name
    end
  end

  it "can update its survey_question" do
    DatabaseCleaner.cleaning do
      group_1 = create_survey_group
      survey = group_1.survey
      group_2 = create_survey_group(survey: survey)
      note = create_note(survey_group: group_1, text: "What is all of this, then?")
      question = note.survey_question

      assert_equal question.question, note.text
      assert_equal question.group_name, note.group_name
      
      note.update_survey_question
      assert_equal question.question, note.text
      assert_equal question.group_name, note.group_name
      
      note.text = "'ere now, what's all this then?"
      note.group_name = group_2.name
      note.save
      note.update_survey_question
      assert_equal question.reload.question, note.text
      assert_equal question.group_name, note.group_name
    end
  end
end