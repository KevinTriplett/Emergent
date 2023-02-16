
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
end