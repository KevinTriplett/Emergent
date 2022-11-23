require "test_helper"

class AdminMembersTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with no members" do
    # Member.delete_all
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

  test "Admin page for editing member" do
    DatabaseCleaner.cleaning do
      get new_admin_member_path
      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "New Member"
      assert_select "input#member_name", nil
      assert_select "input#member_email", nil
      assert_select "input#member_profile_url", nil
      assert_select "input#member_chat_url", nil
      assert_select "input#member_status", nil
      assert_select "input#member_referral", nil
      assert_select "input#member_make_greeter", nil
      # assert_select "input#member_notes", nil
      assert_select "input[value='Create Member']", nil
      assert_select "a", "Cancel"

      member = create_member

      get edit_admin_member_path(id: member.id)
      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Edit Member"
      assert_select "input#member_name", member.name
      assert_select "input#member_email", member.email
      assert_select "input#member_profile_url", member.profile_url
      assert_select "input#member_chat_url", member.chat_url
      assert_select "input#member_status", member.status
      assert_select "input#member_referral", member.referral
      assert_select "input#member_make_greeter", member.make_greeter
      # assert_select "input#member_notes", member.notes
      assert_select "input[value='Create Member']", nil
      assert_select "a", "Cancel"
    end
  end
end
