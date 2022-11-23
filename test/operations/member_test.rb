require 'test_helper'

class MemberOperationTest < MiniTest::Spec
  include ActionMailer::TestHelper
  default_date = "12/08/2022"

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {Member} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        result = Member::Operation::Create.call(
          params: {
            member: {
              name: random_member_name, 
              email: random_email,
              join_timestamp: default_date
            }
          }
        )

        assert result.success?
        member = result[:model]
        assert_equal last_random_member_name, member.name
        assert_equal last_random_email, member.email
      end
    end

    it "Creates {Member} model with non-unique name" do
      existing_member = create_member

      DatabaseCleaner.cleaning do
        result = Member::Operation::Create.call(
          params: {
            member: {
              name: existing_member.name, 
              email: random_email,
              join_timestamp: default_date
            }
          }
        )

        assert result.success?
        member = result[:model]
        assert_equal existing_member.name, member.name
        assert_equal last_random_email, member.email
      end
    end

    it "Creates {Greeter} model" do
      DatabaseCleaner.cleaning do
        result = Member::Operation::Create.call(
          params: {
            member: {
              name: random_member_name, 
              email: random_email,
              join_timestamp: default_date,
              make_greeter: true
            }
          }
        )

        assert result.success?
        member = result[:model]
        assert Greeter.find_by_member_id(member.id)
        assert member.greeter
      end
    # Member.delete_all
  end

    # ----------------
    # failing tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = Member::Operation::Create.call(params: {})

        assert !result.success?
      end
    end

    it "Fails with no name attribute" do
      DatabaseCleaner.cleaning do
        result = Member::Operation::Create.call(
          params: {
            member: {
              name: "", 
              email: random_email,
              join_timestamp: default_date
            }
          }
        )

        assert !result.success?
        assert_equal(["name must be filled"], result["contract.default"].errors.full_messages_for(:name))
      end
    end

    it "Fails with no email attribute" do
      DatabaseCleaner.cleaning do
        result = Member::Operation::Create.call(
          params: {
            member: {
              name: random_member_name, 
              email: "",
              join_timestamp: default_date
            }
          }
        )

        assert !result.success?
        assert_equal(["email must be filled"], result["contract.default"].errors.full_messages_for(:email))
      end
    end

    it "Fails with non-unique email address" do
      DatabaseCleaner.cleaning do
        existing_member = create_member

        result = Member::Operation::Create.call(
          params: {
            member: {
              name: random_member_name, 
              email: existing_member.email,
              join_timestamp: default_date
            }
          }
        )

        assert !result.success?
        assert_equal(["email must be unique"], result["contract.default"].errors.full_messages_for(:email))
      end
    end
  end
end