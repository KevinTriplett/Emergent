
require 'test_helper'

class SurveyInviteTest < MiniTest::Spec
  DatabaseCleaner.clean
  it "creates a token on create" do
    DatabaseCleaner.cleaning do
      invite = create_survey_invite
      assert invite.token
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