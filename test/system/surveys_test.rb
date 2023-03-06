require "application_system_test_case"

class SurveysTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  include Rails.application.routes.url_helpers
  DatabaseCleaner.clean
  include StyleHelper

  test "User can access and take a survey" do
    DatabaseCleaner.cleaning do
      survey_invite = create_survey_invite
      survey = survey_invite.survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey)
      group_2 = create_survey_group(survey: survey, votes_max: 10)
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
        group_position: survey_question_2.group_position,
        question_position: survey_question_2.position
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
        group_position: survey_question_7.group_position,
        question_position: survey_question_7.position
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2

      click_link "< Prev"
      
      # ------------------------------------------------------------------------------
      
      params_hash = {
        token: survey_invite.token,
        group_position: survey_question_2.group_position,
        question_position: survey_question_2.position
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
        group_position: survey_question_7.group_position,
        question_position: survey_question_7.position
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
        group_position: survey_question_11.group_position,
        question_position: survey_question_11.position
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
        group_position: survey_question_7.group_position,
        question_position: survey_question_7.position
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2
      
      click_link "Next >"

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        group_position: survey_question_11.group_position,
        question_position: survey_question_11.position
      }
      assert_current_path survey_path(params_hash)
      assert_selector "a", count: 2
      
      click_link "Finish"

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        group_position: -1,
        question_position: -1
      }
      assert_current_path survey_path(params_hash)
      assert_selector "h1", text: "Thank You for taking our survey!"
    end
  end

  test "User can view and vote on survey notes" do
    DatabaseCleaner.cleaning do
      survey_invite = create_survey_invite
      survey = survey_invite.survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey, votes_max: 30)
      group_2 = create_survey_group(survey: survey, votes_max: 30)

      survey_question_0 = create_survey_question({
        survey_group: group_0,
        question_type: "Instructions",
        question: "This is the instruction for the beginning"
      })
      survey_question_1 = create_survey_question({
        survey_group: group_0,
        question_type: "Question",
        question: "Maybe enter your email address?",
        answer_type: "Email"
      })      
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
      note_4 = create_note({
        survey_group: group_2,
        coords: "30px:500px"
      })
      note_5 = create_note({
        survey_group: group_2,
        coords: "420px:500px"
      })
      note_6 = create_note({
        survey_group: group_2,
        coords: "820px:500px"
      })

      # ------------------------------------------------------------------------------

      visit survey_path(survey_invite.token)

      assert_current_path survey_path(survey_invite.token)
      assert_selector "a", text: "Next >", count: 1

      within "#survey-question-#{survey_question_0.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_0.question
        assert_selector "input[type='email']", count: 0
      end

      within "#survey-question-#{survey_question_1.id}" do
        assert_selector ".survey-question-question", text: survey_question_1.question
        assert_selector "input[type='email']", count: 1
        find(".survey-answer-email input").send_keys("name@example.com")
      end
      sleep 2

      survey_answer_1 = survey_invite.survey_answer_for(survey_question_1.id)
      assert_equal "name@example.com", survey_answer_1.answer

      assert_selector "#survey-question-#{survey_question_2.id}", count: 0

      click_link "Next >"

      # ------------------------------------------------------------------------------

      assert_current_path survey_path(token: survey_invite.token, group_position: group_0.position, question_position: survey_question_3.position)

      within "#survey-question-#{survey_question_3.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_3.question
        assert_selector "input", count: 0
      end

      click_link "Next >"

      # ------------------------------------------------------------------------------

      assert_current_path survey_notes_path(survey_invite.token)

      assert_selector "a", text: "< Prev", count: 1
      assert_selector "a", text: "Next >", count: 0
      assert_selector "a", text: "Finish", count: 1
      assert_selector ".note", count: notes_count = Note.all.count

      Note.all.each do |note|
        url = survey_patch_path(token: survey_invite.token, id: note.survey_question_id)
        assert_selector ".note[data-url='#{url}']", count: 1
        within(".note[data-url='#{url}']") do
          assert_selector ".note-text", text: note.text
          assert_selector ".note-group-name", text: note.group_name
          assert_selector ".vote-up", count: 1
          assert_selector ".vote-down", count: 1
          assert_selector ".vote-count", text: "0"
          assert_selector ".votes-left", text: note.survey_group.votes_max
        end
        assert_selector ".votes-left", text: note.survey_group.votes_max, count: notes_count
      end

      votes_left_hash = {}
      votes_left_hash[group_1.name] = group_1.votes_max
      votes_left_hash[group_2.name] = group_2.votes_max

      # notes = Note.all.map {|n| n}
      # (1..5).each do
      #   note = notes.sample
      #   notes.delete_at( notes.index {|n| n.id == note.id} )
      #   url = survey_patch_path(token: survey_invite.token, id: note.survey_question_id)

      #   within(".note[data-url='#{url}']") do
      #     find(".vote-down").click
      #     assert_selector ".vote-count", text: "0"
      #     assert_selector ".votes-left", text: votes_left_hash[note.group_name]

      #     find(".vote-up").click
      #     sleep 1
      #     assert_selector ".vote-count", text: "1"
      #     assert_selector ".votes-left", text: votes_left_hash[note.group_name] -= 1

      #     find(".vote-up").click
      #     find(".vote-up").click
      #     sleep 1
      #     assert_selector ".vote-count", text: "3"
      #     assert_selector ".votes-left", text: votes_left_hash[note.group_name] -= 2

      #     find(".vote-down").click
      #     sleep 1
      #     assert_selector ".vote-count", text: "2"
      #     assert_selector ".votes-left", text: votes_left_hash[note.group_name] += 1
      #   end
      #   [group_1,group_2].each do |group|
      #     css = ".survey-answer-vote[data-group-id='#{group.id}'] .votes-left"
      #     assert_selector css, text: votes_left_hash[group.name], count: 3
      #   end
      #   survey_answer = survey_invite.survey_answer_for(note.survey_question_id)
      #   assert_equal votes_left_hash[note.group_name], survey_answer.reload.votes_left
      # end

      click_link "< Prev"

      # ------------------------------------------------------------------------------

      assert_current_path survey_path(token: survey_invite.token, group_position: survey_question_3.group_position, question_position: survey_question_3.position)

      group_3 = create_survey_group(survey: survey)
      survey_question_4 = create_survey_question({
        survey_group: group_3,
        question_type: "Instructions",
        question: "This concludes the survey"
      })
      survey_question_5 = create_survey_question({
        survey_group: group_3,
        question_type: "Question",
        question: "Did you like it?",
        answer_type: "Yes/No"
      })
      survey_question_6 = create_survey_question({
        survey_group: group_3,
        question_type: "New Page"
      })
      
      click_link "Next >"
      
      # ------------------------------------------------------------------------------

      assert_current_path survey_notes_path(survey_invite.token)
      assert_selector "a", text: "< Prev", count: 1
      assert_selector "a", text: "Next >", count: 1
      assert_selector "a", text: "Finish", count: 0

      Note.all.each do |note|
        survey_answer = survey_invite.survey_answer_for(note.survey_question_id)
        url = survey_patch_path(token: survey_invite.token, id: note.survey_question_id)
        within(".note[data-url='#{url}']") do
          assert_selector ".note-text", text: note.text
          assert_selector ".note-group-name", text: note.group_name
          assert_selector ".vote-count", text: survey_answer.votes
          assert_selector ".votes-left", text: survey_answer.votes_left
        end
      end

      click_link "Next >"
      
      # ------------------------------------------------------------------------------

      assert_selector "a", text: "< Prev", count: 1
      assert_selector "a", text: "Next >", count: 0
      assert_selector "a", text: "Finish", count: 1
      
      within "#survey-question-#{survey_question_4.id}" do
        assert_selector ".survey-question-instructions", text: survey_question_4.question
        assert_selector "input", count: 0
      end

      within "#survey-question-#{survey_question_5.id}" do
        assert_selector ".survey-question-question", text: survey_question_5.question
        assert_selector "input", count: 2
        within ".survey-answer-yes-no" do
          choose option: "Yes"
        end
      end

      assert_selector "#survey-question-#{survey_question_6.id}", count: 0

      click_link "Finish"

      assert_nothing_raised do
        survey_invite.reload # not deleted, as in tests
      end

      # ------------------------------------------------------------------------------

      params_hash = {
        token: survey_invite.token,
        group_position: -1,
        question_position: -1
      }
      assert_current_path survey_path(params_hash)
      assert_selector "h1", text: "Thank You for taking our survey!"

      # ------------------------------------------------------------------------------

      visit survey_show_results_path(survey_invite.token)
      assert_current_path survey_show_results_path(survey_invite.token)

      survey.ordered_groups.each do |sg|
        within "#survey-group-#{sg.id}" do
          assert_selector ".survey-group-name", text: sg.name
          assert_selector ".survey-group-description", text: sg.description
        end
      end

      survey.ordered_questions.each do |sq|
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
        end
      end
    end
  end

  test "User view update notes in live view" do
    DatabaseCleaner.cleaning do
      invite = create_survey_invite
      survey = invite.survey
      group_0 = create_survey_group(survey: survey)
      group_1 = create_survey_group(survey: survey)
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

      visit survey_notes_path(invite.token)
      assert_current_path survey_notes_path(invite.token)
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
      note_2.update group_name: group_1.name
      note_3.group_color = "#ffffff" # NB: this will change the color of notes 2, 3 and 4
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
