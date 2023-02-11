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
      assert_select "th", "Shadow"
      assert_select "th", "Notes"

      assert_select "td.user-name", user.name
      assert_select "td.user-greeter", ""
      assert_select "td.user-status", user.status
      assert_select "td.user-meeting-datetime", user.when_timestamp.picker_datetime
      assert_select "td.user-shadow", ""
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
      
      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h3", user.name

      assert_select "a.user-profile-button", "🙂 Profile"
      assert_select "a.user-chat-button", "💬 Chat"

      assert_select "td", "Greeter"
      assert_select "td", "Email"
      assert_select "td", "Status"
      assert_select "td.meeting", "Zoom Date/Time\n\n(GMT)"
      assert_select "td", "Shadow"
      assert_select "td", "Notes"
      assert_select "td", "Questions"

      assert_select "td.user-greeter", user.greeter.name
      assert_select "td.user-email", user.email
      assert_select "td.user-status select option[selected='selected']", user.status
      assert_select "td.user-meeting-datetime input[value=?]", user.when_timestamp.picker_datetime
      assert_select "td.user-shadow", user.shadow_greeter.name
      assert_select "td.user-notes", user.notes
      
      user.questions_responses.split(" -:- ").each do |qna|
        q,a = *qna.split("\\")
        assert_select "td.user-questions li", "#{q}\n\n#{a}"
      end

      user.update(greeter_id: nil)
      get admin_user_path(token: user.token)
      assert_select "td.user-greeter", "I will greet"

      user.update(shadow_greeter_id: nil)
      get admin_user_path(token: user.token)
      assert_select "td.user-shadow", "I will shadow"

      user.update(profile_url: nil)
      user.update(chat_url: nil)
    end
  end
end
