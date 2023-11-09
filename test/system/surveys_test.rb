require "application_system_test_case"

class SurveysTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  include Rails.application.routes.url_helpers
  DatabaseCleaner.clean
  include StyleHelper

  test "User can access and take a survey" do
    DatabaseCleaner.cleaning do
      user = create_user
      survey = create_survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey)
      group_2 = create_survey_group(survey: survey, votes_max: 10, name: "Group 2")

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
      survey_question_6b = create_survey_question({
        survey_group: group_1,
        question_type: "New Page"
      })
      survey_question_7 = create_survey_question({
        survey_group: group_1,
        question_type: "Vote",
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
      survey_question_10 = create_survey_question({
        survey_group: group_1,
        question_type: "New Page"
      })
      survey_question_11 = create_survey_question({
        survey_group: group_2,
        question_type: "Question",
        question: "I want to do this",
        answer_type: "Vote"
        })
      survey_question_12 = create_survey_question({
        survey_group: group_2,
        question_type: "Question",
        question: "I want to do that",
        answer_type: "Vote"
      })
      survey_question_13 = create_survey_question({
        survey_group: group_2,
        question_type: "Question",
        question: "I want to do neither",
        answer_type: "Vote"
      })
      survey_answer_3 = survey_answer_4 = survey_answer_5 = survey_answer_8 = survey_answer_9 = nil

      # ------------------------------------------------------------------------------
      # make sure position assignment is correct
      assert_equal [0,1], [group_0,group_1].map(&:position)
      assert_equal [0,1,2,3,4,5], [survey_question_0,survey_question_1,survey_question_2,survey_question_3,survey_question_4,survey_question_5].map(&:position)
      assert_equal [0,1,2,3,4,5], [survey_question_6,survey_question_6b,survey_question_7,survey_question_8,survey_question_9,survey_question_10].map(&:position)
      assert_equal [0,1,2], [survey_question_11,survey_question_12,survey_question_13].map(&:position)

      # ------------------------------------------------------------------------------
      # first make sure can access without an invite
      visit take_survey_path(survey_token: survey.token)
      assert_selector "input", count: 3
      assert_selector "input[name='user_email']"
      assert_selector "input[name='user_name']"

      # test with no input
      click_on "Start Survey"
      sleep 1
      assert_current_path take_survey_path(survey_token: survey.token)
      assert_selector ".flash.error", text: "We're sorry, your name or email address was not found"

      # try false email
      fill_in "The email you used to join Mighty Networks", with: "something@company.com"
      click_on "Start Survey"
      assert_current_path take_survey_path(survey_token: survey.token)
      assert_selector ".flash.error", text: "We're sorry, your name or email address was not found"

      # try false name
      fill_in "The name you use in Emergent Commons", with: "marvin goomble"
      click_on "Start Survey"
      assert_current_path take_survey_path(survey_token: survey.token)
      assert_selector ".flash.error", text: "We're sorry, your name or email address was not found"

      # try good email
      fill_in "The email you used to join Mighty Networks", with: user.email
      click_on "Start Survey"
      assert_current_path survey_path(token: SurveyInvite.first.token)
      assert_equal SurveyInvite.all.count, 1

      SurveyInvite.delete_all
      visit take_survey_path(survey_token: survey.token)

      # try good name
      fill_in "The name you use in Emergent Commons", with: user.name
      click_on "Start Survey"
      assert_equal SurveyInvite.all.count, 1
      assert_current_path survey_path(token: SurveyInvite.first.token)

      SurveyInvite.delete_all

      # ------------------------------------------------------------------------------
      # now with an invite
      survey_invite = create_survey_invite(
        survey: survey,
        user: user
      )
      visit survey_path(survey_invite.token)

      assert_current_path survey_path(survey_invite.token)
      assert_selector "a", count: 1
      assert_selector ".survey-name", text: survey.name
      assert_selector ".survey-description", text: survey.description
      assert_selector "#survey-question-#{survey_question_1.id}", count: 0

      within "#survey-question-#{survey_question_0.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_0.question
        assert_selector "input", count: 0
      end

      # ------------------------------------------------------------------------------

      click_link "Next >"

      params_hash = {
        token: survey_invite.token,
        survey_question_id: survey_question_2.id
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2
      assert_selector "#survey-question-#{survey_question_1.id}", count: 0

      within "#survey-question-#{survey_question_2.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_2.question
        assert_selector "input", count: 0
      end

      within "#survey-question-#{survey_question_3.id}" do
        assert_selector ".survey-question-question", text: survey_question_3.question
        assert_selector ".survey-question-scale-question", text: survey_question_3.scale_question
        assert_selector ".survey-answer-essay textarea", count: 1
        find(".survey-answer-essay textarea").click
        find(".survey-answer-essay textarea").send_keys("This is my")
        sleep 1
        survey_answer_3 = survey_invite.survey_answer_for(survey_question_3.id)
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

      within "#survey-question-#{survey_question_4.id}" do
        assert_selector ".survey-question-question", text: survey_question_4.question
        assert_selector "input", count: 1
        assert_selector ".survey-answer-range input[type='range']", count: 1
        assert_selector ".survey-answer-range label:nth-of-type(1)", text: survey_question_4.answer_labels.split("|")[0]
        assert_selector ".survey-answer-range label:nth-of-type(2)", text: survey_question_4.answer_labels.split("|")[1]
        find(".survey-answer-range input[type='range']").set(10)
        sleep 1
        survey_answer_4 = survey_invite.survey_answer_for(survey_question_4.id)
        assert_equal "10", survey_answer_4.answer
      end

      within "#survey-question-#{survey_question_5.id}" do
        assert_selector ".survey-question-question", text: survey_question_5.question
        assert_selector ".survey-answer-yes-no input[type='radio']", count: 2
        assert_selector ".survey-answer-yes-no label:nth-of-type(1)", text: survey_question_5.answer_labels.split("|")[0]
        assert_selector ".survey-answer-yes-no label:nth-of-type(2)", text: survey_question_5.answer_labels.split("|")[1]
        within ".survey-answer-yes-no" do
          choose option: "Sort Of"
        end
        sleep 1
        survey_answer_5 = survey_invite.survey_answer_for(survey_question_5.id)
        assert_equal "Sort Of", survey_answer_5.answer
      end

      within "#survey-question-#{survey_question_6.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_6.question
        assert_selector "textarea", count: 0
        assert_selector "input", count: 0
      end

      click_link "Next >"

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        survey_question_id: survey_question_7.id
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2

      click_link "< Prev"
      
      # ------------------------------------------------------------------------------
      
      params_hash = {
        token: survey_invite.token,
        survey_question_id: survey_question_2.id
      }
      assert_current_path survey_path(params_hash)

      within "#survey-question-#{survey_question_2.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_2.question
        assert_selector "input", count: 0
      end

      within "#survey-question-#{survey_question_3.id}" do
        assert_selector ".survey-question-question", text: survey_question_3.question
        assert_selector ".survey-answer-essay textarea", text: survey_answer_3.answer
      end

      within "#survey-question-#{survey_question_4.id}" do
        assert_selector ".survey-question-question", text: survey_question_4.question
        assert_selector ".survey-answer-range input[value='#{survey_answer_4.answer}']"
      end

      within "#survey-question-#{survey_question_5.id}" do
        assert_selector ".survey-question-question", text: survey_question_5.question
        assert find(".survey-answer-yes-no input[value='Sort Of']").selected?
      end
      
      click_link "Next >"

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        survey_question_id: survey_question_7.id
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2

      within "#survey-question-#{survey_question_7.id}" do
        assert_selector ".survey-answer-yes-no input[type='radio']", count: 2
        assert_selector ".survey-answer-yes-no label:nth-of-type(1)", text: survey_question_7.answer_labels.split("|")[0]
        assert_selector ".survey-answer-yes-no label:nth-of-type(2)", text: survey_question_7.answer_labels.split("|")[1]
      end

      within "#survey-question-#{survey_question_8.id}" do
        assert_selector "textarea", count: 1
        assert_selector "input", count: 1
        assert_selector ".survey-answer-scale label:nth-of-type(1)", text: survey_question_8.scale_labels.split("|")[0]
        assert_selector ".survey-answer-scale label:nth-of-type(2)", text: survey_question_8.scale_labels.split("|")[1]
        assert_selector ".survey-answer-scale input[type='range']", count: 1
        find(".survey-answer-scale input[type='range']").set(3)
        sleep 1
        survey_answer_8 = survey_invite.survey_answer_for(survey_question_8.id)
        assert_equal 3, survey_answer_8.scale
      end

      within "#survey-question-#{survey_question_9.id}" do
        assert_selector "textarea", count: 0
        assert_selector "input", count: 10
        survey_question_9.answer_labels.split("|").each_with_index do |label, i|
          assert_selector ".survey-answer-multiple-choice label:nth-of-type(#{i+1})", text: label
        end
        within ".survey-answer-multiple-choice" do
          choose option: "Villian"
        end
        sleep 1
        survey_answer_9 = survey_invite.survey_answer_for(survey_question_9.id)
        assert_equal "Villian", survey_answer_9.answer
      end

      click_link "Next >"

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        survey_question_id: survey_question_11.id
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2

      within "#survey-question-#{survey_question_11.id}" do
        assert_selector ".survey-question-question", text: survey_question_11.question
        assert_selector "textarea", count: 0
        assert_selector "input", count: 0
        assert_selector ".vote-up", count: 1
        assert_selector ".vote-down", count: 1
        assert_selector ".vote-count", text: "0"
        assert_selector ".votes-left", text: "10"
      end

      within "#survey-question-#{survey_question_12.id}" do
        assert_selector ".survey-question-question", text: survey_question_12.question
        assert_selector "textarea", count: 0
        assert_selector "input", count: 0
        assert_selector ".vote-up", count: 1
        assert_selector ".vote-down", count: 1
        assert_selector ".vote-count", text: "0"
        assert_selector ".votes-left", text: "10"
      end

      within "#survey-question-#{survey_question_13.id}" do
        assert_selector ".survey-question-question", text: survey_question_13.question
        assert_selector "textarea", count: 0
        assert_selector "input", count: 0
        assert_selector ".vote-up", count: 1
        assert_selector ".vote-down", count: 1
        assert_selector ".vote-count", text: "0"
        assert_selector ".votes-left", text: "10"
      end

      within "#survey-question-#{survey_question_12.id}" do
        find(".vote-up").click
        sleep 2
        assert_selector ".vote-count", text: "1"
        assert_selector ".votes-left", text: "9"
      end
      within "#survey-question-#{survey_question_11.id}" do
        assert_selector ".vote-count", text: "0"
        assert_selector ".votes-left", text: "9"
      end
      within "#survey-question-#{survey_question_13.id}" do
        assert_selector ".vote-count", text: "0"
        assert_selector ".votes-left", text: "9"
      end

      within "#survey-question-#{survey_question_13.id}" do
        find(".vote-up").click
        sleep 1
        find(".vote-up").click
        sleep 1
        find(".vote-up").click
        sleep 1
        find(".vote-up").click
        sleep 2
        assert_selector ".vote-count", text: "4"
        assert_selector ".votes-left", text: "5"
      end
      within "#survey-question-#{survey_question_11.id}" do
        assert_selector ".vote-count", text: "0"
        assert_selector ".votes-left", text: "5"
      end
      within "#survey-question-#{survey_question_12.id}" do
        assert_selector ".vote-count", text: "1"
        assert_selector ".votes-left", text: "5"
      end
      
      within "#survey-question-#{survey_question_11.id}" do
        find(".vote-up").click
        sleep 1
        find(".vote-up").click
        sleep 2
        assert_selector ".vote-count", text: "2"
        assert_selector ".votes-left", text: "3"
      end
      within "#survey-question-#{survey_question_12.id}" do
        assert_selector ".vote-count", text: "1"
        assert_selector ".votes-left", text: "3"
      end
      within "#survey-question-#{survey_question_13.id}" do
        assert_selector ".vote-count", text: "4"
        assert_selector ".votes-left", text: "3"
      end

      within "#survey-question-#{survey_question_13.id}" do
        find(".vote-down").click
        sleep 1
        find(".vote-down").click
        sleep 2
        assert_selector ".vote-count", text: "2"
        assert_selector ".votes-left", text: "5"
      end
      within "#survey-question-#{survey_question_11.id}" do
        assert_selector ".vote-count", text: "2"
        assert_selector ".votes-left", text: "5"
      end
      within "#survey-question-#{survey_question_12.id}" do
        assert_selector ".vote-count", text: "1"
        assert_selector ".votes-left", text: "5"
      end
      
      click_link "< Prev"

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        survey_question_id: survey_question_7.id
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2
      
      click_link "Next >"

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        survey_question_id: survey_question_11.id
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2
      
      click_link "Finish"

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        survey_question_id: -1
      }
      assert_current_path survey_path(params_hash)
      assert_selector "h1", text: "Thank You for taking our survey!"
    end
  end

  test "User can view and vote on survey notes" do
    DatabaseCleaner.cleaning do
      survey = create_survey(create_initial_questions: true)

      survey_question_1a = survey.ordered_questions[0]
      survey_question_1b = survey.ordered_questions[1]
      survey_question_5  = survey.ordered_questions[2]

      survey_invite = create_survey_invite(survey: survey)
      user = survey_invite.user
      group_0 = survey.survey_groups[0]
      group_1 = create_survey_group(survey: survey, votes_max: 30, name: "Group 1")
      group_2 = create_survey_group(survey: survey, votes_max: 30, name: "Group 2")
      group_3 = create_survey_group(survey: survey, votes_max: 30, name: "Group 3")
      group_4 = create_survey_group(survey: survey, votes_max: 30, name: "Group 4")
      group_5 = survey.survey_groups[1]
      group_5.update position: survey.survey_groups.count
      survey.fixup_positions

      survey_question_2 = create_survey_question({
        survey_group: group_0,
        question_type: "New Page"
      })      
      survey_question_3 = create_survey_question({
        survey_group: group_0,
        question_type: "Instructions",
        question: "This is the instruction for the notes"
      })
      note_1 = create_note({
        survey_group: group_1,
        coords: "30px:130px"
      })
      note_2 = create_note({
        survey_group: group_1,
        coords: "420px:130px"
      })
      note_3 = create_note({
        survey_group: group_1,
        coords: "820px:130px"
      })
      survey_question_4 = create_survey_question({
        survey_group: group_2,
        question_type: "Instructions",
        question: "Now consider these notes",
        answer_type: "Email"
      })      
      note_4 = create_note({
        survey_group: group_3,
        coords: "30px:500px"
      })
      note_5 = create_note({
        survey_group: group_3,
        coords: "420px:500px"
      })
      note_6 = create_note({
        survey_group: group_3,
        coords: "820px:500px"
      })
      note_7 = create_note({
        survey_group: group_4,
        coords: "30px:500px"
      })
      note_8 = create_note({
        survey_group: group_4,
        coords: "420px:500px"
      })
      note_9 = create_note({
        survey_group: group_4,
        coords: "820px:500px"
      })

      # ------------------------------------------------------------------------------

      visit survey_path(token: survey_invite.token)

      assert_current_path survey_path(survey_invite.token)
      assert_selector "a", text: "Next >", count: 1

      within "#survey-question-#{survey_question_1a.id}" do
        assert_selector ".survey-question-question", text: survey_question_1a.question
        assert_selector "input", count: 3
        survey_question_1a.answer_labels.split("|").each_with_index do |label, i|
          assert_selector ".survey-answer-multiple-choice label:nth-of-type(#{i+1})", text: label
        end
        within ".survey-answer-multiple-choice" do
          choose option: "Email"
        end
      end

      within "#survey-question-#{survey_question_1b.id}" do
        assert_selector ".survey-question-question", text: survey_question_1b.question
        assert_selector "input[type='email']", count: 1
        find(".survey-answer-email input").send_keys(user.email)
      end
      sleep 1

      answer = survey_invite.survey_answers.where(survey_question_id: survey_question_1b.id).first
      assert_equal user.email, answer.answer

      assert_selector "#survey-question-#{survey_question_2.id}", count: 0

      click_link "Next >"

      # ------------------------------------------------------------------------------

      assert_current_path survey_path(token: survey_invite.token, survey_question_id: survey_question_3.id)
      within "#survey-question-#{survey_question_3.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_3.question
        assert_selector "input", count: 0
      end

      click_link "Next >"

      # ------------------------------------------------------------------------------

      assert_current_path survey_path(survey_invite.token, survey_question_id: note_1.survey_question_id)

      assert_selector "a", text: "< Prev", count: 1
      assert_selector "a", text: "Next >", count: 1
      assert_selector "a", text: "Finish", count: 0
      assert_selector ".note", count: notes_count = 3

      [note_1,note_2,note_3].each do |note|
        url = survey_patch_path(token: survey_invite.token, id: note.survey_question_id)
        assert_selector ".note[data-url='#{url}']", count: 1
        within(".note[data-url='#{url}']") do
          assert_selector ".note-text", text: note.text
          assert_selector ".note-group-name", text: note.group_name
          assert_selector ".vote-up", count: 1
          assert_selector ".vote-down", count: 1
          assert_selector ".vote-count", text: "0"
        end
      end

      note_1.survey_group.update votes_max: 3
      within(".note#note-#{note_1.id}") do
        assert_selector ".vote-count", text: "0"
        assert_selector ".hearts i.one-third", count: 0
        assert_selector ".hearts i.two-thirds", count: 0
        assert_selector ".hearts i.three-thirds", count: 0
        find(".vote-up").click
        sleep 1
        assert_selector ".vote-count", text: "1"
        assert_selector ".hearts i.one-third", count: 1
        assert_selector ".hearts i.two-thirds", count: 0
        assert_selector ".hearts i.three-thirds", count: 0
        find(".vote-up").click
        sleep 1
        assert_selector ".vote-count", text: "2"
        assert_selector ".hearts i.one-third", count: 0
        assert_selector ".hearts i.two-thirds", count: 1
        assert_selector ".hearts i.three-thirds", count: 0
        find(".vote-up").click
        sleep 1
        assert_selector ".vote-count", text: "3"
        assert_selector ".hearts i.one-third", count: 0
        assert_selector ".hearts i.two-thirds", count: 0
        assert_selector ".hearts i.three-thirds", count: 1
      end

      votes_left_hash = {}
      votes_left_hash[group_1.name] = group_1.votes_max
      votes_left_hash[group_2.name] = group_2.votes_max

      assert_selector ".note#note-#{note_1.id}"
      assert_selector ".note#note-#{note_2.id}"
      assert_selector ".note#note-#{note_3.id}"
      assert_no_selector ".note#note-#{note_4.id}"
      assert_no_selector ".note#note-#{note_5.id}"
      assert_no_selector ".note#note-#{note_6.id}"
      assert_no_selector ".note#note-#{note_7.id}"
      assert_no_selector ".note#note-#{note_8.id}"
      assert_no_selector ".note#note-#{note_9.id}"

      assert_selector ".note#note-#{note_1.id} .note-text", text: note_1.text
      assert_selector ".note#note-#{note_2.id} .note-text", text: note_2.text
      assert_selector ".note#note-#{note_3.id} .note-text", text: note_3.text

      click_link "Next >"

      # ------------------------------------------------------------------------------

      assert_current_path survey_path(survey_invite.token, survey_question_id: survey_question_4.id)

      within "#survey-question-#{survey_question_4.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_4.question
        assert_selector "input", count: 0
      end

      click_link "Next >"

      # ------------------------------------------------------------------------------

      assert_current_path survey_path(survey_invite.token, survey_question_id: note_4.survey_question_id)

      assert_selector "a", text: "< Prev", count: 1
      assert_selector "a", text: "Next >", count: 1
      assert_selector "a", text: "Finish", count: 0
      assert_selector ".note", count: notes_count = 6

      assert_no_selector ".note#note-#{note_1.id}"
      assert_no_selector ".note#note-#{note_2.id}"
      assert_no_selector ".note#note-#{note_3.id}"
      assert_selector ".note#note-#{note_4.id}"
      assert_selector ".note#note-#{note_5.id}"
      assert_selector ".note#note-#{note_6.id}"
      assert_selector ".note#note-#{note_7.id}"
      assert_selector ".note#note-#{note_8.id}"
      assert_selector ".note#note-#{note_9.id}"

      assert_selector ".note#note-#{note_4.id} .note-text", text: note_4.text
      assert_selector ".note#note-#{note_5.id} .note-text", text: note_5.text
      assert_selector ".note#note-#{note_6.id} .note-text", text: note_6.text
      assert_selector ".note#note-#{note_7.id} .note-text", text: note_7.text
      assert_selector ".note#note-#{note_8.id} .note-text", text: note_8.text
      assert_selector ".note#note-#{note_9.id} .note-text", text: note_9.text

      click_link "< Prev"

      # ------------------------------------------------------------------------------

      assert_current_path survey_path(survey_invite.token, survey_question_id: survey_question_4.id)

      click_link "Next >"
      
      # ------------------------------------------------------------------------------

      assert_current_path survey_path(survey_invite.token, survey_question_id: note_4.survey_question_id)

      [note_4,note_5,note_6,note_7,note_8,note_9].each do |note|
        survey_answer = survey_invite.survey_answer_for(note.survey_question_id)
        url = survey_patch_path(token: survey_invite.token, id: note.survey_question_id)
        within(".note[data-url='#{url}']") do
          assert_selector ".note-text", text: note.text
          assert_selector ".note-group-name", text: note.group_name
          assert_selector ".vote-count", text: survey_answer.votes
        end
      end

      click_link "Next >"
      
      # ------------------------------------------------------------------------------

      assert_current_path survey_path(survey_invite.token, survey_question_id: survey_question_5.id)

      assert_selector "a", text: "< Prev", count: 1
      assert_selector "a", text: "Next >", count: 0
      assert_selector "a", text: "Finish", count: 1
      
      within "#survey-question-#{survey_question_5.id}" do
        assert_selector ".survey-question-question", text: survey_question_5.question
        assert_selector ".survey-question-scale-question", text: survey_question_5.scale_question
        assert_selector ".survey-answer-essay textarea", count: 1
        find(".survey-answer-essay textarea").click
        find(".survey-answer-essay textarea").send_keys("This was a great survey!")
        assert_selector ".survey-answer-scale label:nth-of-type(1)", text: survey_question_5.scale_labels.split("|")[0]
        assert_selector ".survey-answer-scale label:nth-of-type(2)", text: survey_question_5.scale_labels.split("|")[1]
        assert_selector ".survey-answer-scale input[type='range']", count: 1
        find(".survey-answer-scale input[type='range']").set(3)
      end

      click_link "Finish"

      assert_nothing_raised do
        survey_invite.reload # not deleted, as in tests
      end
      assert survey_invite.is_finished?

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        survey_question_id: -1
      }
      assert_current_path survey_path(params_hash)
      assert_selector "h1", text: "Thank You for taking our survey!"

      # ------------------------------------------------------------------------------

      visit survey_show_results_path(token: survey_invite.token)
      assert_current_path survey_show_results_path(token: survey_invite.token)

      survey.ordered_groups.each do |sg|
        within "#survey-group-#{sg.id}" do
          assert_selector ".survey-group-name", text: sg.name
          assert_selector ".survey-group-description", text: sg.description
        end
      end

      survey.ordered_questions.each do |sq|
        within "#survey-group-#{sq.survey_group_id}" do
          within "#survey-question-#{sq.id}" do
            question_css = ".survey-question-#{sq.question_type.downcase.gsub(" ", "-").gsub("/", "-")}"
            answer_css = ".survey-answer-#{sq.answer_type.downcase.gsub(" ", "-").gsub("/", "-")}"
            assert_selector question_css, text: sq.question
            next if sq.na?
            answer = survey_invite.survey_answer_for(sq.id)
            assert_selector answer_css, text: /#{answer.answer}/
            next unless sq.has_scale?
            assert_selector ".survey-question-scale-question", text: sq.scale_question
            assert_selector ".survey-answer-scale", text: answer.scale
            next unless sq.note?
            assert_selector ".survey-question-vote", text: "You gave this #{amswer.votes} votes"
            thirds = answer.vote_thirds
            assert_selector ".survey-question-vote i.one-third", count: 1 == thirds ? 1 : 0
            assert_selector ".survey-question-vote i.two-thirds", count: 2 == thirds ? 1 : 0
            assert_selector ".survey-question-vote i.three-thirds", count: 3 == thirds ? 1 : 0
          end
        end
      end
    end
  end

  test "User view update notes in live view" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      invite = create_survey_invite(survey: survey)
      group_0 = create_survey_group(survey: survey, name: "Group 0")
      group_1 = create_survey_group(survey: survey, name: "Group 1")
      note_1 = create_note({
        survey_group: group_0,
        coords: "30px:130px"
      })
      note_2 = create_note({
        survey_group: group_0,
        coords: "420px:130px"
      })
      note_3 = create_note({
        survey_group: group_1,
        coords: "820px:130px"
      })
      note_4 = create_note({
        survey_group: group_1,
        coords: "30px:500px"
      })
      Note.all.each do |note|
        create_survey_answer(survey_question: note.survey_question, survey_invite: invite)
      end

      # check when liveview disabled

      visit survey_path(invite.token, survey_question_id: note_1.survey_question_id)
      assert_current_path survey_path(invite.token, survey_question_id: note_1.survey_question_id)

      note_1.update text: "Change is definitely good for ya!"
      note_2.update group_name: group_1.name
      note_3.group_color = "#cc0088" # NB: this will change the color of notes 2, 3 and 4
      note_3.save
      note_4.update coords: "42px:55px"
      sleep 7

      assert_selector "#note-template", visible: :hidden, count: 1
      assert_no_selector ".note#note-#{note_1.id} .note-text", text: note_1.text
      assert_no_selector ".note#note-#{note_2.id} .note-group-name", text: note_2.group_name
      assert computed_style(".note#note-#{note_3.id}", "background-color").paint.to_hex != note_3.group_color
      assert computed_style(".note#note-#{note_4.id}", "left") != "#{note_4.coords.split(":")[0]}"
      assert computed_style(".note#note-#{note_4.id}", "top") != "#{note_4.coords.split(":")[1]}"

      # now check when liveview enabled
      survey.update liveview: true

      visit survey_path(invite.token, survey_question_id: note_1.survey_question_id)
      assert_current_path survey_path(invite.token, survey_question_id: note_1.survey_question_id)
      assert_selector "#note-template", visible: :hidden, count: 1

      Note.all.each do |note|
        assert_equal computed_style(".note#note-#{note.id}", "background-color").paint.to_hex, note.group_color
        assert_equal computed_style(".note#note-#{note.id}", "left"), "#{note.coords.split(":")[0]}"
        assert_equal computed_style(".note#note-#{note.id}", "top"), "#{note.coords.split(":")[1]}"
        assert_selector ".note#note-#{note.id} .note-group-name", text: note.group_name
        assert_selector ".note#note-#{note.id} .note-text", text: note.text
      end

      sleep 2
      note_1.update text: "Change is good for ya!"
      note_2.update group_name: group_0.name
      note_3.group_color = "#0022cc" # NB: this will change the color of notes 2, 3 and 4
      note_3.save
      note_4.update coords: "420px:550px"
      sleep 7

      assert_selector "#note-template", visible: :hidden, count: 1
      Note.all.each do |note|
        assert_equal computed_style(".note#note-#{note.id}", "background-color").paint.to_hex, note.group_color
        assert_equal computed_style(".note#note-#{note.id}", "left"), "#{note.coords.split(":")[0]}"
        assert_equal computed_style(".note#note-#{note.id}", "top"), "#{note.coords.split(":")[1]}"
        assert_selector ".note#note-#{note.id} .note-group-name", text: note.group_name
        assert_selector ".note#note-#{note.id} .note-text", text: note.text
      end

      Note::Operation::Delete.call(params: {id: note_4.id})
      sleep 7
      assert_selector "#notes-container .note", count: 3
      assert_selector "#note-template", visible: :hidden, count: 1
    end
  end
end
