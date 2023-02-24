require "application_system_test_case"

class SurveysTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "User can access and take a survey" do
    DatabaseCleaner.cleaning do
      survey_invite = create_survey_invite
      survey = survey_invite.survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey)
      user = survey_invite.user

      survey_question_0 = create_survey_question({
        survey_group: group_0,
        question_type: "Instructions",
        question: "This is the instruction for the beginning"
      })
      survey_question_1 = create_survey_question({
        survey_group: group_0,
        question_type: "New Page"
      })
      survey_question_2 = create_survey_question({
        survey_group: group_0,
        question_type: "Instructions",
        question: "Choose and answer the one question that seems most important to you:"
      })
      survey_question_3 = create_survey_question({
        survey_group: group_0,
        question_type: "Question",
        question: "This is the 1st question of Group 1",
        answer_type: "Essay",
        has_scale: "1",
        scale_question: "How important it this to you?",
        scale_labels: "Not so much|A lot"
      })
      survey_question_4 = create_survey_question({
        survey_group: group_0,
        question_type: "Question",
        answer_type: "Range",
        answer_labels: "Left Side|Right Side",
        question: "This is the 2st question of Group 1",
        has_scale: "0"
      })
      survey_question_5 = create_survey_question({
        survey_group: group_0,
        question_type: "Question",
        question: "This is the 3st question of Group 1",
        answer_type: "Yes/No",
        answer_labels: "Maybe|Sort Of",
        has_scale: "1"
      })
      survey_question_6 = create_survey_question({
        survey_group: group_1,
        question_type: "Instructions",
        question: "This begins the questions in group 2"
      })
      survey_question_7 = create_survey_question({
        survey_group: group_1,
        question_type: "Question",
        question: "This is the 4st question overall but the 1st of Group 2"
      })
      survey_question_8 = create_survey_question({
        survey_group: group_1,
        question_type: "Question",
        question: "This is the 5st question overall but the 2st of Group 2",
        answer_type: "Essay",
        has_scale: "1"
      })
      survey_question_9 = create_survey_question({
        survey_group: group_1,
        question_type: "Question",
        question: "This is the 6st question - which do you prefer?",
        answer_type: "Multiple Choice",
        answer_labels: "Hero|Heroine|Villian|Outcast|Warrior|Adventurer|Professor|Wizard|Witch|Shaman"
      })

      # make sure position assignment is correct
      assert_equal [0,1], [group_0,group_1].map(&:position)
      assert_equal [0,1,2,3,4,5], [survey_question_0,survey_question_1,survey_question_2,survey_question_3,survey_question_4,survey_question_5].map(&:position)
      assert_equal [0,1,2,3], [survey_question_6,survey_question_7,survey_question_8,survey_question_9].map(&:position)

      survey_answer_3 = survey_answer_4 = survey_answer_5 = survey_answer_8 = survey_answer_9 = nil

      visit survey_path(token: survey_invite.token)
      assert_current_path survey_path(token: survey_invite.token)
      
      assert_selector "a", count: 1
      assert_selector ".survey-name", text: survey.name
      assert_selector ".survey-description", text: survey.description

      within "#survey-question-#{survey_question_0.group_position}-#{survey_question_0.position}" do
        assert_selector ".survey-question-instructions", text: survey_question_0.question
        assert_selector "input", count: 0
      end

      assert_selector "#survey-question-#{survey_question_1.group_position}-#{survey_question_1.position}", count: 0
      
      click_link "Next >"
      puts "Next"

      params_hash = {
        token: survey_invite.token,
        group_position: survey_question_2.group_position,
        question_position: survey_question_2.position
      }
      assert_current_path survey_path(params_hash)

      assert_selector "a", count: 2
      assert_selector "#survey-question-#{survey_question_1.group_position}-#{survey_question_1.position}", count: 0

      within "#survey-question-#{survey_question_2.group_position}-#{survey_question_2.position}" do
        assert_selector ".survey-question-instructions", text: survey_question_2.question
        assert_selector "input", count: 0
      end

      within "#survey-question-#{survey_question_3.group_position}-#{survey_question_3.position}" do
        assert_selector ".survey-question-question", text: survey_question_3.question
        assert_selector ".survey-answer-scale-question", text: survey_question_3.scale_question
        assert_selector ".survey-answer-essay textarea", count: 1
        find(".survey-answer-essay textarea").click
        find(".survey-answer-essay textarea").send_keys("This is my")
        sleep 1
        survey_answer_3 = survey_invite.survey_answers.where(survey_question_id: survey_question_3.id).first
        assert_equal "This is my", survey_answer_3.answer
        find(".survey-answer-essay textarea").send_keys(" answer")
        assert_selector ".survey-answer-scale label:nth-of-type(1)", text: survey_question_3.scale_labels.split("|")[0]
        assert_selector ".survey-answer-scale label:nth-of-type(2)", text: survey_question_3.scale_labels.split("|")[1]
        assert_selector ".survey-answer-scale input[type='range']", count: 1
        find(".survey-answer-scale input[type='range']").set(0)
        sleep 1
        assert_equal "This is my answer", survey_answer_3.reload.answer
        assert_equal 0, survey_answer_3.scale
      end

      within "#survey-question-#{survey_question_4.group_position}-#{survey_question_4.position}" do
        assert_selector ".survey-question-question", text: survey_question_4.question
        assert_selector "input", count: 1
        assert_selector ".survey-answer-range input[type='range']", count: 1
        assert_selector ".survey-answer-range label:nth-of-type(1)", text: survey_question_4.answer_labels.split("|")[0]
        assert_selector ".survey-answer-range label:nth-of-type(2)", text: survey_question_4.answer_labels.split("|")[1]
        find(".survey-answer-range input[type='range']").set(10)
        sleep 1
        survey_answer_4 = survey_invite.survey_answers.where(survey_question_id: survey_question_4.id).first
        assert_equal "10", survey_answer_4.answer
      end

      within "#survey-question-#{survey_question_5.group_position}-#{survey_question_5.position}" do
        assert_selector ".survey-question-question", text: survey_question_5.question
        assert_selector ".survey-answer-yes-no input[type='radio']", count: 2
        assert_selector ".survey-answer-yes-no label:nth-of-type(1)", text: survey_question_5.answer_labels.split("|")[0]
        assert_selector ".survey-answer-yes-no label:nth-of-type(2)", text: survey_question_5.answer_labels.split("|")[1]
        within ".survey-answer-yes-no" do
          choose option: "Sort Of"
        end
        sleep 1
        survey_answer_5 = survey_invite.survey_answers.where(survey_question_id: survey_question_5.id).first
        assert_equal "Sort Of", survey_answer_5.answer
      end

      puts "Next"
      click_link "Next >"

      params_hash = {
        token: survey_invite.token,
        group_position: survey_question_6.group_position,
        question_position: survey_question_6.position
      }
      assert_current_path survey_path(params_hash)
      
      puts "Prev"
      click_link "< Prev"

      params_hash = {
        token: survey_invite.token,
        group_position: survey_question_2.group_position,
        question_position: survey_question_2.position
      }
      assert_current_path survey_path(params_hash)

      within "#survey-question-#{survey_question_2.group_position}-#{survey_question_2.position}" do
        assert_selector ".survey-question-instructions", text: survey_question_2.question
        assert_selector "input", count: 0
      end

      within "#survey-question-#{survey_question_3.group_position}-#{survey_question_3.position}" do
        assert_selector ".survey-question-question", text: survey_question_3.question
        assert_selector ".survey-answer-essay textarea", text: survey_answer_3.answer
      end

      within "#survey-question-#{survey_question_4.group_position}-#{survey_question_4.position}" do
        assert_selector ".survey-question-question", text: survey_question_4.question
        assert_selector ".survey-answer-range input[value='#{survey_answer_4.answer}']"
      end

      within "#survey-question-#{survey_question_5.group_position}-#{survey_question_5.position}" do
        assert_selector ".survey-question-question", text: survey_question_5.question
        assert find(".survey-answer-yes-no input[value='Sort Of']").selected?
      end
      
      puts "Next"
      click_link "Next >"

      params_hash = {
        token: survey_invite.token,
        group_position: survey_question_6.group_position,
        question_position: survey_question_6.position
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2

      within "#survey-question-#{survey_question_6.group_position}-#{survey_question_6.position}" do
        assert_selector ".survey-question-instructions", text: survey_question_6.question
        assert_selector "textarea", count: 0
        assert_selector "input", count: 0
      end

      within "#survey-question-#{survey_question_7.group_position}-#{survey_question_7.position}" do
        assert_selector ".survey-answer-yes-no input[type='radio']", count: 2
        assert_selector ".survey-answer-yes-no label:nth-of-type(1)", text: survey_question_7.answer_labels.split("|")[0]
        assert_selector ".survey-answer-yes-no label:nth-of-type(2)", text: survey_question_7.answer_labels.split("|")[1]
      end

      within "#survey-question-#{survey_question_8.group_position}-#{survey_question_8.position}" do
        assert_selector "textarea", count: 1
        assert_selector "input", count: 1
        assert_selector ".survey-answer-scale label:nth-of-type(1)", text: survey_question_8.scale_labels.split("|")[0]
        assert_selector ".survey-answer-scale label:nth-of-type(2)", text: survey_question_8.scale_labels.split("|")[1]
        assert_selector ".survey-answer-scale input[type='range']", count: 1
        find(".survey-answer-scale input[type='range']").set(3)
        sleep 1
        survey_answer_8 = survey_invite.survey_answers.where(survey_question_id: survey_question_8.id).first
        assert_equal 3, survey_answer_8.scale
      end

      within "#survey-question-#{survey_question_9.group_position}-#{survey_question_9.position}" do
        assert_selector "textarea", count: 0
        assert_selector "input", count: 10
        survey_question_9.answer_labels.split("|").each_with_index do |label, i|
          assert_selector ".survey-answer-multiple-choice label:nth-of-type(#{i+1})", text: label
        end
        within ".survey-answer-multiple-choice" do
          choose option: "Villian"
        end
        sleep 1
        survey_answer_9 = survey_invite.survey_answers.where(survey_question_id: survey_question_9.id).first
        assert_equal "Villian", survey_answer_9.answer
      end

      puts "Finish"
      click_link "Finish"

      params_hash = {
        token: survey_invite.token,
        group_position: -1,
        question_position: -1
      }
      assert_current_path survey_path(params_hash)
      assert_selector "h1", text: "Thank You for taking our survey!"
    end
  end
end
