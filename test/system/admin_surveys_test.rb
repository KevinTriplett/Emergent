require "application_system_test_case"

class AdminSurveysTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "Regular user cannot create a survey" do
    visit admin_surveys_path
    assert_current_path root_path
  end

  test "Admin can create and edit a survey" do
    DatabaseCleaner.cleaning do
      admin = login

      visit admin_surveys_path
      assert_current_path admin_surveys_path
      click_link "New Survey"

      assert_current_path new_admin_survey_path
      survey_description = "This are the description"
      fill_in "Name", with: random_survey_name
      fill_in "Description", with: survey_description
      click_on "Create Survey"

      sleep 1
      survey = Survey.first
      assert survey
      assert_current_path new_admin_survey_survey_question_path(survey_id: survey.id)
      click_link "Cancel"

      assert_current_path admin_survey_path(survey.id)
      click_link "Back"

      assert_current_path admin_surveys_path
      assert_selector ".survey-name", text: survey.name
      click_link "edit"

      assert_current_path edit_admin_survey_path(survey.id)
      assert_selector :field, "Name", with: survey.name
      assert_selector :field, "Description", with: survey.description
      click_link "Cancel"

      assert_current_path admin_surveys_path
      click_link "edit"

      assert_current_path edit_admin_survey_path(survey.id)
      fill_in "Name", with: random_survey_name
      click_on "Update Survey"

      sleep 1
      assert_equal last_random_survey_name, survey.reload.name
      assert_current_path admin_survey_path(survey.id)
      assert_selector ".survey-name", text: survey.name
    end
  end

  test "Admin can create and edit survey questions" do
    DatabaseCleaner.cleaning do
      admin = login
      existing_survey = create_survey

      visit admin_survey_path(existing_survey.id)
      assert_current_path admin_survey_path(existing_survey.id)
      assert_selector "table tbody tr", count: 0
      click_link "New Question"

      assert_current_path new_admin_survey_survey_question_path(survey_id: existing_survey.id)

      question_type = SurveyQuestion::QUESTION_TYPES[1]
      find("#question-type .ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: question_type, exact_text: true).click
      assert_selector ".ui-selectmenu-text", text: question_type

      answer_type = SurveyQuestion::ANSWER_TYPES[1]
      find("#answer-type .ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: answer_type, exact_text: true).click
      assert_selector ".ui-selectmenu-text", text: answer_type

      question = "This is the querstion"
      fill_in "Question", with: question
      uncheck "Has Scale"

      click_on "Create Question"

      sleep 1
      survey_question = SurveyQuestion.first
      assert question_type, survey_question.question_type
      assert answer_type, survey_question.answer_type
      assert question, survey_question.question

      visit admin_survey_path(existing_survey.id)
      assert_selector "td.question-type", text: survey_question.question_type
      assert_selector "td.answer-type", text: survey_question.answer_type
      assert_selector "td.question", text: survey_question.question
      assert_selector "td.has-scale", text: survey_question.has_scale ? "Yes" : "No"
      within("table.survey-questions") do
        click_link "edit"
      end

      assert_current_path edit_admin_survey_survey_question_path(survey_question.id, survey_id: existing_survey.id)

      question_type = SurveyQuestion::QUESTION_TYPES[0]
      find("#question-type .ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: question_type, exact_text: true).click
      assert_selector ".ui-selectmenu-text", text: question_type

      answer_type = SurveyQuestion::ANSWER_TYPES[0]
      find("#answer-type .ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: answer_type, exact_text: true).click
      assert_selector ".ui-selectmenu-text", text: answer_type

      question = "This is a revised querstion"
      fill_in "Question", with: question
      check "Has Scale"

      click_on "Update Question"
      assert_current_path admin_survey_survey_question_path(survey_question.id, survey_id: existing_survey.id)

      fill_in "Scale Question", with: "What's it to youi?"
      fill_in "Scale Labels (separated by | delimiter)", with: "Lo|Hi"
      click_on "Update Question"

      assert_current_path admin_survey_path(existing_survey.id)
      survey_question.reload
      assert_equal question_type, survey_question.question_type
      assert_equal answer_type, survey_question.answer_type
      assert_equal question, survey_question.question
      assert survey_question.has_scale
      assert_selector "td.question-type", text: survey_question.question_type
      assert_selector "td.answer-type", text: survey_question.answer_type
      assert_selector "td.question", text: survey_question.question
      assert_selector "td.has-scale", text: survey_question.has_scale ? "Yes" : "No"
    end
  end

  test "Admin can re-ordering survey questions" do
    DatabaseCleaner.cleaning do
      admin = login
      existing_survey = create_survey
      survey_question_1 = create_survey_question({
        survey: existing_survey,
        question: "This is the 1th question"
      })
      survey_question_2 = create_survey_question({
        survey: existing_survey,
        question: "This is the 2th question"
      })
      survey_question_3 = create_survey_question({
        survey: existing_survey,
        question: "This is the 3th question"
      })
      assert_equal 0, survey_question_1.position
      assert_equal 1, survey_question_2.position
      assert_equal 2, survey_question_3.position

      visit admin_survey_path(existing_survey.id)
      assert_selector "tbody tr:nth-child(1) td.question", text: survey_question_1.question
      assert_selector "tbody tr:nth-child(2) td.question", text: survey_question_2.question
      assert_selector "tbody tr:nth-child(3) td.question", text: survey_question_3.question
      source = page.find("tbody tr:nth-child(1)")
      target = page.find("tbody tr:nth-child(3)")
      source.drag_to(target)
      assert_selector "tbody tr:nth-child(1) td.question", text: survey_question_2.question
      assert_selector "tbody tr:nth-child(2) td.question", text: survey_question_3.question
      assert_selector "tbody tr:nth-child(3) td.question", text: survey_question_1.question
      sleep 1
      assert_equal 2, survey_question_1.reload.position
      assert_equal 0, survey_question_2.reload.position
      assert_equal 1, survey_question_3.reload.position
    end
  end
end
