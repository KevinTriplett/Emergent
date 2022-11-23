require 'test_helper'

class GreeterOperationTest < MiniTest::Spec
  include ActionMailer::TestHelper

  describe "Create" do
    DatabaseCleaner.clean

    # ----------------
    # happy path tests
    it "Creates {Greeter} model when given valid attributes" do
      DatabaseCleaner.cleaning do
        existing_member = create_member

        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: existing_member.id, 
              status: "active",
              order_permanent: 1,
              order_temporary: 2
            }
          }
        )

        assert result.success?
        greeter = result[:model]
        assert_equal existing_member.name, greeter.member.name
        assert_equal 1, greeter.order_permanent
        assert_equal 2, greeter.order_temporary
      end
    end

    # ----------------
    # failing tests
    it "Fails with invalid parameters" do
      DatabaseCleaner.cleaning do
        result = Greeter::Operation::Create.call(params: {})

        assert !result.success?
      end
    end

    it "Fails with no member_id attribute" do
      DatabaseCleaner.cleaning do
        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: nil,
              status: "active",
              order_permanent: 1,
              order_temporary: 2
            }
          }
        )

        assert !result.success?
        assert_equal(["member_id must be filled"], result["contract.default"].errors.full_messages_for(:member_id))
      end
    end

    it "Fails with invalid member_id attribute" do
      DatabaseCleaner.cleaning do
        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: "Kevin",
              status: "active",
              order_permanent: 1,
              order_temporary: 2
            }
          }
        )

        assert !result.success?
        assert_equal(["member_id must be an integer"], result["contract.default"].errors.full_messages_for(:member_id))
      end
    end

    it "Fails with no status attribute" do
      DatabaseCleaner.cleaning do
        existing_member = create_member

        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: existing_member.id,
              status: "",
              order_permanent: 1,
              order_temporary: 2
            }
          }
        )

        assert !result.success?
        assert_equal(["status must be filled"], result["contract.default"].errors.full_messages_for(:status))
      end
    end

    it "Fails with invalid status attribute" do
      DatabaseCleaner.cleaning do
        existing_member = create_member
        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: existing_member.id,
              status: 1,
              order_permanent: 1,
              order_temporary: 2
            }
          }
        )

        assert !result.success?
        assert_equal(["status must be a string"], result["contract.default"].errors.full_messages_for(:status))
      end
    end

    it "Fails with no order_permanent attribute" do
      DatabaseCleaner.cleaning do
        existing_member = create_member

        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: existing_member.id,
              status: 1,
              order_permanent: nil,
              order_temporary: 2
            }
          }
        )

        assert !result.success?
        assert_equal(["order_permanent must be filled"], result["contract.default"].errors.full_messages_for(:order_permanent))
      end
    end

    it "Fails with invalid order_permanent attribute" do
      DatabaseCleaner.cleaning do
        existing_member = create_member

        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: existing_member.id,
              status: 1,
              order_permanent: "Kevin",
              order_temporary: 2
            }
          }
        )

        assert !result.success?
        assert_equal(["order_permanent must be an integer"], result["contract.default"].errors.full_messages_for(:order_permanent))
      end
    end

    it "Fails with no order_temporary attribute" do
      DatabaseCleaner.cleaning do
        existing_member = create_member

        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: existing_member.id,
              status: 1,
              order_permanent: 1,
              order_temporary: nil
            }
          }
        )

        assert !result.success?
        assert_equal(["order_temporary must be filled"], result["contract.default"].errors.full_messages_for(:order_temporary))
      end
    end

    it "Fails with invalid order_temporary attribute" do
      DatabaseCleaner.cleaning do
        existing_member = create_member

        result = Greeter::Operation::Create.call(
          params: {
            greeter: {
              member_id: existing_member.id,
              status: 1,
              order_permanent: 1,
              order_temporary: "Kevin"
            }
          }
        )

        assert !result.success?
        assert_equal(["order_temporary must be an integer"], result["contract.default"].errors.full_messages_for(:order_temporary))
      end
    end
  end
end