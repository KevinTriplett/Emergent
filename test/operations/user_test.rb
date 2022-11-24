require 'test_helper'

class UserOperationTest < MiniTest::Spec
  include ActionMailer::TestHelper
  default_date = "12/08/2022"

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {User} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        result = create_user_with_result({
          name: random_user_name, 
          email: random_email,
          join_timestamp: default_date
        })

        assert result.success?
        user = result[:model]
        assert_equal last_random_user_name, user.name
        assert_equal last_random_email, user.email
      end
    end

    it "Creates {User} model with non-unique name" do
      DatabaseCleaner.cleaning do
        existing_user = create_user

        result = create_user_with_result({
          name: existing_user.name, 
          email: random_email,
          join_timestamp: default_date
        })

        assert result.success?
        user = result[:model]
        assert_equal existing_user.name, user.name
        assert_equal last_random_email, user.email
      end
    end

    # ----------------
    # failing tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = User::Operation::Create.call(params: {})
        assert !result.success?
      end
    end

    it "Fails with no name attribute" do
      DatabaseCleaner.cleaning do
        result = create_user_with_result({
          name: "", 
          email: random_email,
          join_timestamp: default_date
        })

        assert !result.success?
        assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
      end
    end

    it "Fails with no email attribute" do
      DatabaseCleaner.cleaning do
        result = create_user_with_result({
          name: random_user_name, 
          email: "",
          join_timestamp: default_date
        })

        assert !result.success?
        assert_equal(["email must be filled"], result["contract.default"].errors.full_messages_for(:email))
      end
    end

    it "Fails with non-unique email address" do
      DatabaseCleaner.cleaning do
        existing_user = create_user

        result = create_user_with_result({
          name: random_user_name, 
          email: existing_user.email,
          join_timestamp: default_date
        })

        assert !result.success?
        assert_equal(["email must be unique"], result["contract.default"].errors.full_messages_for(:email))
      end
    end
  end
end