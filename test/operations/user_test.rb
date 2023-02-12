require 'test_helper'

class UserOperationTest < MiniTest::Spec
  include ActionMailer::TestHelper
  default_date = Time.now - 1.days

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
        greeter = create_user
        existing_user = create_user

        # NB: user_hash = existing_user.attributes <-- this does not work
        user_hash = {
          model: {
            greeter_id: greeter.id
          },
          token: existing_user.token
        }
        result = User::Operation::Patch.call(params: user_hash, admin_name: admin.name)

        assert result.success?
        existing_user.reload
        assert_equal greeter.name, existing_user.greeter.name
      end
    end

    it "Clears when_timestamp on status change" do
      DatabaseCleaner.cleaning do
        test_date = "2023 Jan 20 10:00"
        admin = create_user
        existing_user = create_user(when_timestamp: test_date)
        assert existing_user.when_timestamp

        user_hash = {
          model: {
            status: "Zoom Scheduled"
          },
          token: existing_user.token
        }
        result = User::Operation::Patch.call(params: user_hash, admin_name: admin.name)
        assert_nil existing_user.reload.when_timestamp
        existing_user.update(when_timestamp: test_date)

        user_hash = {
          model: {
            status: "Scheduling Zoom"
          },
          token: existing_user.token
        }
        result = User::Operation::Patch.call(params: user_hash, admin_name: admin.name)
        assert_nil existing_user.reload.when_timestamp
        existing_user.update(when_timestamp: test_date)

        user_hash = {
          model: {
            status: "Zoom Done (completed)"
          },
          token: existing_user.token
        }
        result = User::Operation::Patch.call(params: user_hash, admin_name: admin.name)
        assert_nil existing_user.reload.when_timestamp
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
        greeter_1 = create_user
        greeter_2 = create_user
        admin = create_user
        existing_user = create_user(notes: "")

        assert_nil existing_user.change_log
        user_hash = {
          model: {
            status: "New Status"
          },
          token: existing_user.token
        }
        result = User::Operation::Patch.call(params: user_hash, admin_name: admin.name)
        assert result.success?
        timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC")
        new_change_log = [
          "#{timestamp} by #{admin.name}:",
          "- status changed: #{existing_user.status} -> New Status",
          "- when_timestamp changed: #{existing_user.when_timestamp} -> (blank)\n"
        ].join("\n")
        assert_equal new_change_log, existing_user.reload.change_log

        random_user_name_1, random_user_name_2 = random_user_name, random_user_name
        when_timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC")
        user_hash = {
          model: {
            notes: "Replacing all the notes",
            when_timestamp: when_timestamp,
            greeter_id: greeter_1.id,
            shadow_greeter_id: greeter_2.id
          },
          token: existing_user.token
        }
        # when_timestamp = when_timestamp.strftime("%Y-%m-%d %H:%M:%S -0600")
        result = User::Operation::Patch.call(params: user_hash, admin_name: admin.name)
        assert result.success?
        timestamp = Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC")
        new_change_log += "#{timestamp} by #{admin.name}:\n"
        new_change_log += "- notes changed: (blank) -> Replacing all the notes\n"
        new_change_log += "- when_timestamp changed: (blank) -> #{when_timestamp}\n"
        new_change_log += "- greeter changed: (blank) -> #{greeter_1.name}\n"
        new_change_log += "- shadow_greeter changed: (blank) -> #{greeter_2.name}\n"
        assert_equal new_change_log, existing_user.reload.change_log
      end
    end
  end
end