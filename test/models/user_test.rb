require 'test_helper'

class UserTest < MiniTest::Spec
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  it "ensures the user has a token and session token" do
    DatabaseCleaner.cleaning do
      user = create_user
      assert user.token
      user.token = nil
      assert_nil user.token
      user.ensure_token
      assert user.token

      assert_nil user.session_token
      st = user.generate_session_token
      assert user.session_token
      assert_equal st, user.session_token
    end
  end

  it "can abbreviate notes" do
    DatabaseCleaner.cleaning do
      user = create_user
      a = ""
      16.times {|i| a += "A"}
      user.notes = a
      assert_equal a, user.notes_abbreviated
      user.notes += "A"
      assert_equal "#{a}...", user.notes_abbreviated
    end
  end

  it "can get status options from class" do
    DatabaseCleaner.cleaning do
      user = create_user
      status_options = [
        "Pending",
        "Joined!",
        "1st Email Sent",
        "2nd Email Sent",
        "Emailing",
        "No Response",
        "Rescheduling",
        "Follow Up",
        "Will Call",
        "Greet Scheduled",
        "Declined",
        "Welcomed",
        "Posted Intro",
        "Completed"
      ]
      assert_equal status_options, User.get_status_options
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