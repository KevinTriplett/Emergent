require 'test_helper'

class SurveyAnswersTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "delegates survey attributes" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      user = create_user
      survey_invite = create_survey_invite({
        survey: survey,
        user: user
      })
      survey_group = create_survey_group(survey: survey)
      survey_question = create_survey_question(survey_group: survey_group)
      survey_answer = create_survey_answer({
        survey_invite: survey_invite,
        survey_question: survey_question
      })

      assert_equal user.id, survey_answer.user.id
      assert_equal survey.id, survey_answer.survey.id
    end
  end

  it "delegates survey_question attributes" do
    DatabaseCleaner.cleaning do
      survey_question = create_survey_question
      survey_answer = create_survey_answer(survey_question: survey_question)

      assert_equal survey_question.question_type, survey_answer.question_type
      assert_equal survey_question.question, survey_answer.question
      assert_equal survey_question.has_scale?, survey_answer.has_scale?
      assert_equal survey_question.answer_type, survey_answer.answer_type
    end
  end

  it "allows votes = nil" do
    DatabaseCleaner.cleaning do
      answer = create_survey_answer
      assert_nil answer.vote_count
      assert_equal 0, answer.votes
      
      answer.votes = nil
      answer.save
      assert 0, answer.reload.vote_count
      assert_equal 0, answer.votes
    end
  end

  it "reports votes and votes_left that are numbers" do
    DatabaseCleaner.cleaning do
      group = create_survey_group(votes_max: 5)
      question = create_survey_question(survey_group: group, answer_type: "Vote")
      invite = create_survey_invite(survey_id: group.survey_id)
      answer = create_survey_answer(survey_invite: invite, survey_question_id: question.id)

      assert_equal 0, answer.votes
      assert_equal 5, answer.votes_left

      answer.votes = 2
      answer.save
      assert_equal 2, answer.reload.votes
      assert_equal 2, answer.votes_total
      assert_equal 5, answer.votes_max
      assert_equal 3, answer.votes_left
    end
  end

  it "reports the vote count left with multiple questions" do
    DatabaseCleaner.cleaning do
      group = create_survey_group(votes_max: 7)
      question_1 = create_survey_question({
        survey_group: group,
        question_type: "Question",
        question: "Do you like this?",
        answer_type: "Vote"
      })
      question_2 = create_survey_question({
        survey_group: group,
        question_type: "Question",
        question: "What about this?",
        answer_type: "Vote"
      })
      question_3 = create_survey_question({
        survey_group: group,
        question_type: "Question",
        question: "And this?",
        answer_type: "Vote"
      })
      invite = create_survey_invite(survey_id: group.survey_id)
      answer_1 = create_survey_answer(survey_invite: invite, survey_question: question_1)
      answer_1.votes = 1
      answer_1.save
      assert_equal 6, answer_1.reload.votes_left
      assert_equal 1, answer_1.votes
      assert_equal 1, answer_1.votes_total
      answer_2 = create_survey_answer(survey_invite: invite, survey_question: question_2)
      answer_2.votes =  2
      answer_2.save
      assert_equal 4, answer_2.reload.votes_left
      assert_equal 2, answer_2.votes
      assert_equal 3, answer_2.votes_total
      answer_3 = create_survey_answer(survey_invite: invite, survey_question: question_3)
      answer_3.votes =  3
      answer_3.save
      assert_equal 1, answer_3.reload.votes_left
      assert_equal 3, answer_3.votes
      assert_equal 6, answer_3.votes_total
      answer_3.votes =  5
      answer_3.save
      assert_equal 0, answer_3.reload.votes_left
      assert_equal 4, answer_3.votes
      assert_equal 7, answer_3.votes_total
    end
  end

  it "respects votes_left" do
    DatabaseCleaner.cleaning do
      group = create_survey_group(votes_max: 5)
      question = create_survey_question(survey_group: group, answer_type: "Vote")
      invite = create_survey_invite(survey_id: group.survey_id)
      answer = create_survey_answer(survey_invite: invite, survey_question: question)

      assert_equal 5, answer.votes_left
      answer.votes = 6
      answer.save
      assert_equal 5, answer.reload.votes
      assert_equal 0, answer.votes_left
      answer.votes = -1
      answer.save
      assert_equal 0, answer.reload.votes
      assert_equal 5, answer.votes_left
    end
  end
end
