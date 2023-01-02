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

    it "Updates {User} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        admin = create_user
        existing_user = create_user
        existing_user.greeter = random_user_name

        # user_hash = existing_user.attributes <-- this does not work
        user_hash = {
          user: {
            name: existing_user.name,
            email: existing_user.email,
            profile_url: existing_user.profile_url,
            chat_url: existing_user.chat_url,
            request_timestamp: existing_user.request_timestamp.dow_short_date,
            join_timestamp: existing_user.join_timestamp.dow_short_date,
            status: existing_user.status,
            location: existing_user.location,
            questions_responses: existing_user.questions_responses,
            notes: existing_user.notes,
            referral: existing_user.referral,
            greeter: existing_user.greeter
          },
          id: existing_user.id
        }
        result = User::Operation::Update.call(params: user_hash, current_user: admin)

        assert result.success?
        user = result[:model]
        assert_equal existing_user.name, user.name
        assert_equal last_random_user_name, user.greeter
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

    it "tracks changes to user" do
      DatabaseCleaner.cleaning do
        admin = create_user
        existing_user = create_user

        assert_nil existing_user.change_log
        user_hash = {
          user: {
            status: "New Status",
            notes: existing_user.notes,
            welcome_timestamp: existing_user.welcome_timestamp,
            greeter: existing_user.greeter,
            shadow_greeter: existing_user.shadow_greeter
          },
          id: existing_user.id
        }
        result = User::Operation::Update.call(params: user_hash, current_user: admin)
        assert result.success?
        timestamp = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
        new_change_log = "#{timestamp} by #{admin.name}:\n- status changed: #{existing_user.status} -> New Status\n"
        assert_equal new_change_log, existing_user.reload.change_log

        user_hash = {
          user: {
            status: existing_user.status,
            notes: "Replacing all the notes",
            welcome_timestamp: existing_user.welcome_timestamp,
            greeter: existing_user.greeter,
            shadow_greeter: existing_user.shadow_greeter
          },
          id: existing_user.id
        }
        result = User::Operation::Update.call(params: user_hash, current_user: admin)
        assert result.success?
        timestamp = Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
        new_change_log += "#{timestamp} by #{admin.name}:\n- notes changed: #{existing_user.notes} -> Replacing all the notes\n"
        assert_equal new_change_log, existing_user.reload.change_log
      end
    end
  end
end