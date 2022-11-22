require "test_helper"

class AdminMembersTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with no members" do
    DatabaseCleaner.cleaning do
      get admin_members_path
  
      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "No Existing Members"
    end
  end

  test "Admin page with members" do
    DatabaseCleaner.cleaning do
      member = create_member

      get admin_members_path
      assert_select "h5", "Existing Members"
    end
  end
end
