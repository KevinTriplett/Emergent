require "application_system_test_case"

class SurveysTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "User can access and take a survey" do
    DatabaseCleaner.cleaning do
      survey_invite = create_survey_invite
      survey = survey_invite.survey
      user = survey_invite.user

      survey_question_0 = create_survey_question({
        survey: survey,
        question_type: "Instruction",
        question: "This is the instruction for the beginning"
      })
      survey_question_1 = create_survey_question({
        survey: survey,
        question_type: "New Page"
      })
      survey_question_2 = create_survey_question({
        survey: survey,
        question_type: "Instructions",
        question: "Choose and answer the one question that seems most important to you:"
      })
      survey_question_3 = create_survey_question({
        survey: survey,
        question_type: "Question",
        question: "This is the 1st question",
        has_scale: true
      })
      survey_question_4 = create_survey_question({
        survey: survey,
        question_type: "Question",
        question: "This is the 2st question",
        has_scale: true
      })
      survey_question_5 = create_survey_question({
        survey: survey,
        question_type: "Question",
        question: "This is the 3st question",
        has_scale: true
      })
      survey_question_6 = create_survey_question({
        survey: survey,
        question_type: "New Page",
        question: "This question will not be shown"
      })
      survey_question_7 = create_survey_question({
        survey: survey,
        question_type: "Instructions",
        question: "These are instructions for the next questions"
      })
      survey_question_8 = create_survey_question({
        survey: survey,
        question_type: "Question",
        question: "This is the 4st question"
      })
      survey_question_9 = create_survey_question({
        survey: survey,
        question_type: "Question",
        question: "This is the 5st question"
      })

      visit survey_path(token: survey_invite.token)
      assert_current_path survey_path(token: survey_invite.token)
      assert_selector ".survey-description", text: survey.description
      survey_question_id = "#survey-question-#{survey_question_0.id}"
      assert_selector "#{survey_question_id} .survey-question.instructions", text: survey_question_0.question
      click_link "Start"

      assert_current_path survey_invite_survey_question_path(token: survey_invite, id: survey_question_2.id)

      survey_question_id = "#survey-question-#{survey_question_2.id}"
      assert_selector "#{survey_question_id} .survey-question", text: survey_question_2.question

      survey_question_id = "#survey-question-#{survey_question_3.id}"
      assert_selector "#{survey_question_id} .survey-question", text: survey_question_3.question
      assert_selector "#{survey_question_id} .survey-question-scale", text: ""

      survey_question_id = "#survey-question-#{survey_question_4.id}"
      assert_selector "#{survey_question_id} .survey-question", text: survey_question_4.question

      survey_question_id = "#survey-question-#{survey_question_5.id}"
      assert_selector "#{survey_question_id} .survey-question", text: survey_question_5.question
      click_link "Next"

      assert_current_path survey_invite_survey_question_path(token: survey_invite, id: survey_question_7.id)
      click_link "Next"

      # test "Prev" link
    end
  end
end
