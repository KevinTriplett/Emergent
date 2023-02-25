require 'test_helper'

class SurveyGroupTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "gives an ordered list of questions" do
    DatabaseCleaner.cleaning do
      group = create_survey_group
      question_1 = create_survey_question(survey_group: group)
      question_2 = create_survey_question(survey_group: group)
      question_3 = create_survey_question(survey_group: group)

      assert_equal [question_1.id, question_2.id, question_3.id], group.survey_questions.map(&:id)
      assert_equal [question_1.id, question_2.id, question_3.id], group.ordered_questions.map(&:id)

      question_1.update position: 3
      question_2.update position: 2
      question_3.update position: 1
      assert_equal [question_1.id, question_2.id, question_3.id], group.survey_questions.map(&:id)
      assert_equal [question_3.id, question_2.id, question_1.id], group.ordered_questions.map(&:id)
    end
  end

  it "gives an ordered list of notes" do
    DatabaseCleaner.cleaning do
      group = create_survey_group
      note_1 = create_note(survey_group: group)
      note_2 = create_note(survey_group: group)
      note_3 = create_note(survey_group: group)

      assert_equal [note_1.id, note_2.id, note_3.id], group.notes.map(&:id)
      assert_equal [note_1.id, note_2.id, note_3.id], group.ordered_notes.map(&:id)

      note_1.update position: 3
      note_2.update position: 2
      note_3.update position: 1
      assert_equal [note_1.id, note_2.id, note_3.id], group.notes.map(&:id)
      assert_equal [note_3.id, note_2.id, note_1.id], group.ordered_notes.map(&:id)
    end
  end
end