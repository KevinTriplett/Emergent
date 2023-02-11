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
end