require "test_helper"

class SurveysTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "User can access page with invite" do
    DatabaseCleaner.cleaning do
      invite = create_survey_invite
      survey = invite.survey
      group = create_survey_group(survey: survey)
      question = create_survey_question(survey_group: group)

      get survey_path(invite.token)
      assert_response :success
      assert_not_nil assigns(:survey_questions)

      assert_select "h1", "Emergent Commons Survey"
      assert_select ".survey-name", survey.name
      assert_select "#survey-questions-container", count: 1
      assert_select ".survey-question-question", "#{question.question}\n\n Yes No"
      assert_select "a[href=?]", survey_path(token: invite.token, group_position: "-1", question_position: "-1"), "Finish"
    end
  end

  test "User cam see notes and live views are enabled" do
    DatabaseCleaner.cleaning do
      invite = create_survey_invite
      survey = invite.survey
      group = create_survey_group(survey: survey)
      question = create_survey_question(survey_group: group)
      note_1 = create_note(survey_group: group)
      note_2 = create_note(survey_group: group)

      get survey_path(invite.token)
      get survey_notes_path(invite.token)

      assert_select ".live-view[data-timestamp=?]", note_2.updated_at.picker_datetime
      assert_select ".live-view[data-url=?]", survey_live_view_path(invite.token)

      # TODO: test for not live-view (updated_at before X time)
    end
  end

  # TODO: test for notes and different types of questions and answers
end