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

  it "set and get roles with order" do
    DatabaseCleaner.cleaning do
      user1 = create_user
      assert user1.get_role(:greeter).blank?
      assert !user1.has_role?(:greeter)
      user1.add_role(:greeter, {order: 0})
      assert_equal 0, user1.get_role(:greeter)[:order]
      assert user1.has_role?(:greeter)

      # does not double-up
      user1.add_role(:greeter, {order: 1})
      assert_equal 0, user1.get_role(:greeter)[:order]

      # second greeter gets the next order
      user2 = create_user
      assert_equal 0, user1.get_role(:greeter)[:order]
      assert user2.get_role(:greeter).blank?
      assert !user2.has_role?(:greeter)
      user2.add_role(:greeter, {order: 0})
      assert_equal 0, user1.get_role(:greeter)[:order]
      assert_equal 1, user2.get_role(:greeter)[:order]
      assert user2.has_role?(:greeter)

      # third greeter gets shifted down when
      # second greeter is removed
      # and first greeter is untouched
      user3 = create_user
      user3.add_role(:greeter, {order: 0})
      assert_equal 2, user3.get_role(:greeter)[:order]
      user2.remove_role(:greeter)
      assert !user2.has_role?(:greeter)
      assert_equal 0, user1.get_role(:greeter)[:order]
      assert_equal 1, user3.reload.get_role(:greeter)[:order]
    end
  end
end