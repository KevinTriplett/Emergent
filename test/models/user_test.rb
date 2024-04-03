require 'test_helper'

class UserTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "generates, regenerates and revokes tokens" do
    DatabaseCleaner.cleaning do
      user = create_user
      assert user.token
      assert_nil user.session_token

      user.generate_tokens
      assert user.token
      assert user.session_token
      
      old_token = user.token
      old_session_token = user.session_token
      user.regenerate_tokens
      assert_equal old_token, user.token
      assert user.session_token != old_session_token

      user.revoke_tokens
      assert user.token
      assert_nil user.session_token
    end
  end

  it "locks and unlocks user" do
    DatabaseCleaner.cleaning do
      user = create_user
      assert !user.locked?

      user.lock
      assert user.reload.locked?

      user.unlock
      assert !user.reload.locked?
    end
  end

  it "abbreviates notes" do
    DatabaseCleaner.cleaning do
      user = create_user(notes: "12345678901234567890123456789012345678901234567890123456789012345678901234567890")
      assert_equal "12345678901234567...", user.notes_abbreviated
    end
  end

  it "returns questions responses in an array" do
    DatabaseCleaner.cleaning do
      user = create_user
      assert_equal [["1q","1a"],["2q","2a"],["3q","3a"],["4q","4a"],["5q","5a"]], user.questions_responses_array
    end
  end

  it "destroys dependent survey_invites" do
    DatabaseCleaner.cleaning do
      user = create_user
      survey = create_survey
      invite = create_survey_invite(survey: survey, user: user)
      user.destroy
      assert survey.reload.present?
      assert_raises ActiveRecord::RecordNotFound do
        user.reload
      end
      assert_raises ActiveRecord::RecordNotFound do
        invite.reload
      end
    end
  end
end