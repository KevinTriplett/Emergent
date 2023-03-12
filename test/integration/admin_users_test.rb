require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with unauthorized user" do
    get admin_users_path
    assert_response :redirect
  end

  test "Admin page with authorized user but first visit" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      get admin_users_path
      assert_response :redirect
    end
  end

  test "Admin page with authorized user" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      get admin_users_path
      assert_response :success
      assert_not_nil assigns(:users)

      assert_select ".current-user", "Hi  ^_^\nLogout"
      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Greeter View"
    end
  end

  test "Admin page with users" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      get admin_users_path
      assert_response :success
      
      assert_select "h5", "Greeter View"
      assert_select "h1", "Emergent Commons Volunteer App"

      assert_select "th", "Name"
      assert_select "th", "Greeter"
      assert_select "th", "Status"
      assert_select "th.meeting", "Zoom Meeting\n\n(GMT)"
      # assert_select "th", "Shadow"
      assert_select "th", "Notes"

      assert_select "td.user-name", user.name
      assert_select "td.user-greeter", ""
      assert_select "td.user-status", user.status
      assert_select "td.user-meeting-datetime", user.when_timestamp.picker_datetime
      # assert_select "td.user-shadow", "I want to shadow"
      assert_select "td.user-notes", user.notes_abbreviated
    end
  end

  test "Admin page with user" do
    DatabaseCleaner.cleaning do
      greeter_1 = create_user
      greeter_2 = create_user
      user = create_authorized_user({
        greeter_id: greeter_1.id,
        shadow_greeter_id: greeter_2.id
      })
      set_authorization_cookie

      get admin_user_path(token: user.token)
      
      assert_select ".user-name", user.name

      assert_select "a.user-profile-button", "🙂 Profile"
      assert_select "a.user-chat-button", "💬 Chat"

      assert_select ".user-greeter", "Greeter:\n#{user.greeter.name}"
      assert_select ".user-email", "Email address:\n#{user.email}"
      # assert_select ".user-status span.ui-selectmenu-text", user.status
      assert_select "p.user-greeting-date", "Greeting on #{user.when_timestamp.picker_datetime}"
      assert_select ".user-notes", "Notes\n(Record anything here that a greeter might need to know, in case you need to turn over this greeting)\n#{user.notes}"
      assert_select ".user-greeter", "Greeter: #{user.greeter.name}"
      assert_select ".user-status select option[selected='selected']", user.status
      
      user.questions_responses_array.each do |q, a|
        assert_select ".user-questions li", "#{q}\n\n#{a}"
      end

      user.update(greeter_id: nil)
      get admin_user_path(token: user.token)
      assert_select ".user-greeter", "Greeter: (nobody)"

      user.update(profile_url: nil)
      user.update(chat_url: nil)
    end
  end
end
