require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  #
  # for cookiejar info ref https://philna.sh/blog/2020/01/15/test-signed-cookies-in-rails/
  #

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
      create_authorized_user
      set_authorization_cookie

      get admin_users_path
      assert_response :success
      assert_not_nil assigns(:users)

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Existing Members"
    end
  end

  test "Admin page with users" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user({
        greeter: random_user_name,
        shadow_greeter: random_user_name
      })
      set_authorization_cookie

      get admin_users_path
      assert_response :success
      
      assert_select "h5", "Existing Members"
      assert_select "h1", "Emergent Commons Volunteer App"

      assert_select "th", "Name"
      assert_select "th", "Greeter"
      assert_select "th", "Email"
      assert_select "th", "Status"
      assert_select "th.meeting", "When\n\n(GMT)"
      assert_select "th", "Shadow"
      assert_select "th", "Requested"

      assert_select "td.user-greeter", user.greeter
      assert_select "td.user-email", user.email
      assert_select "td.user-status select option[selected='selected']", user.status
      assert_select "td.user-meeting-datetime input[value=?]", user.welcome_timestamp.picker_datetime
      assert_select "td.user-shadow", user.shadow_greeter
      assert_select "td.user-requested-date", user.request_timestamp.picker_date
      
      user.update(greeter: nil)
      get admin_users_path
      assert_select "td.user-greeter", "I will greet"

      user.update(shadow_greeter: nil)
      get admin_users_path
      assert_select "td.user-shadow", "I will shadow"
    end
  end

  test "Admin page with user" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user({
        greeter: random_user_name,
        shadow_greeter: random_user_name
      })
      set_authorization_cookie

      get admin_user_path(user.id)
      
      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h3", user.name

      assert_select "a.user-profile-button", "😊 Profile"
      assert_select "a.user-chat-button", "💬 Chat"

      assert_select "td", "Greeter"
      assert_select "td", "Email"
      assert_select "td", "Status"
      assert_select "td.meeting", "When\n\n(GMT)"
      assert_select "td", "Shadow"
      assert_select "td", "Notes"
      assert_select "td", "Questions"

      assert_select "td.user-greeter", user.greeter
      assert_select "td.user-email", user.email
      assert_select "td.user-status select option[selected='selected']", user.status
      assert_select "td.user-meeting-datetime input[value=?]", user.welcome_timestamp.picker_datetime
      assert_select "td.user-shadow", user.shadow_greeter
      assert_select "td.user-notes", user.notes
      
      user.questions_responses.split(" -:- ").each do |qna|
        q,a = *qna.split("\\")
        assert_select "td.user-questions li", "#{q}\n\n#{a}"
      end

      user.update(greeter: nil)
      get admin_user_path(user.id)
      assert_select "td.user-greeter", "I will greet"

      user.update(shadow_greeter: nil)
      get admin_user_path(user.id)
      assert_select "td.user-shadow", "I will shadow"

      user.update(profile_url: nil)
      user.update(chat_url: nil)
    end
  end
end
