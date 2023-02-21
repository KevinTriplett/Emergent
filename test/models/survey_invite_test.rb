
require 'test_helper'

class SurveyInviteTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "creates a token on create" do
    DatabaseCleaner.cleaning do
      invite = create_survey_invite
      assert invite.token
    end
  end

  it "updates the state" do
    DatabaseCleaner.cleaning do
      survey_invite = create_survey_invite
      assert_equal SurveyInvite::STATUS[:created], survey_invite.state

      survey_invite.update_state(:sent)
      assert_equal SurveyInvite::STATUS[:sent], survey_invite.reload.state
      survey_invite.update_state(:opened, false)
      assert_equal SurveyInvite::STATUS[:sent], survey_invite.reload.state
    end
  end

  it "reports the queued survey_invites" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      survey_invite_1 = create_survey_invite(survey: survey)
      survey_invite_2 = create_survey_invite(survey: survey)
      survey_invite_3 = create_survey_invite(survey: survey)
      survey_invite_2.update_state(:sent)

      assert_equal [survey_invite_1.id, survey_invite_3.id], SurveyInvite.queued.collect(&:id)
    end
  end

  it "delegates ordered_questions to survey" do
    DatabaseCleaner.cleaning do
      survey = create_survey
      survey_question_1 = create_survey_question(survey: survey)
      survey_question_2 = create_survey_question(survey: survey)
      survey_question_3 = create_survey_question(survey: survey)
      survey_invite = create_survey_invite(survey: survey)

      assert_equal [survey_question_1.id, survey_question_2.id, survey_question_3.id], survey_invite.ordered_questions.collect(&:id)
    end
  end

  it "reports the correct state" do
    DatabaseCleaner.cleaning do
      invite = SurveyInvite.new
      assert invite.created?
      assert invite.is_created
      assert !invite.sent?
      assert !invite.is_sent
      assert !invite.opened?
      assert !invite.is_opened
      assert !invite.started?
      assert !invite.is_started
      assert !invite.finished?
      assert !invite.is_finished

      invite.state = SurveyInvite::STATUS[:sent]
      assert invite.created?
      assert !invite.is_created
      assert invite.sent?
      assert invite.is_sent
      assert !invite.opened?
      assert !invite.is_opened
      assert !invite.started?
      assert !invite.is_started
      assert !invite.finished?
      assert !invite.is_finished

      invite.state = SurveyInvite::STATUS[:opened]
      assert invite.created?
      assert !invite.is_created
      assert invite.sent?
      assert !invite.is_sent
      assert invite.opened?
      assert invite.is_opened
      assert !invite.started?
      assert !invite.is_started
      assert !invite.finished?
      assert !invite.is_finished

      invite.state = SurveyInvite::STATUS[:started]
      assert invite.created?
      assert !invite.is_created
      assert invite.sent?
      assert !invite.is_sent
      assert invite.opened?
      assert !invite.is_opened
      assert invite.started?
      assert invite.is_started
      assert !invite.finished?
      assert !invite.is_finished

      invite.state = SurveyInvite::STATUS[:finished]
      assert invite.created?
      assert !invite.is_created
      assert invite.sent?
      assert !invite.is_sent
      assert invite.opened?
      assert !invite.is_opened
      assert invite.started?
      assert !invite.is_started
      assert invite.finished?
      assert invite.is_finished
    end
  end

  it "reports the vote count left" do
    DatabaseCleaner.cleaning do
      survey = create_survey(vote_max: 7)
      question_1 = create_survey_question({
        question_type: "Question",
        question: "Do you like this?",
        answer_type: "Vote"
      })
      question_2 = create_survey_question({
        question_type: "Question",
        question: "What about this?",
        answer_type: "Vote"
      })
      question_3 = create_survey_question({
        question_type: "Question",
        question: "And this?",
        answer_type: "Vote"
      })
      invite = create_survey_invite(survey: survey)
      answer_1 = create_survey_answer(survey_invite: invite, survey_question_id: question_1.id)
      answer_1.votes = 1
      answer_1.save
      assert_equal 6, invite.votes_left
      answer_2 = create_survey_answer(survey_invite: invite, survey_question_id: question_2.id)
      answer_2.votes =  2
      answer_2.save
      assert_equal 4, invite.reload.votes_left
      answer_3 = create_survey_answer(survey_invite: invite, survey_question_id: question_3.id)
      answer_3.votes =  3
      answer_3.save
      assert_equal 1, invite.reload.votes_left
      answer_3.votes =  5
      answer_3.save
      assert_equal 0, invite.reload.votes_left
      assert_equal 4, answer_3.votes
    end 
  end
end