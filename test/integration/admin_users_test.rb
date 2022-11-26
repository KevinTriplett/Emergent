require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with no users" do
    # User.delete_all
    DatabaseCleaner.cleaning do
      get admin_users_path
  
      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "No Existing Members"
    end
  end

  test "Admin page with users" do
    DatabaseCleaner.cleaning do
      user = create_user

      get admin_users_path
      
      assert_select "h5", "Existing Members"
      assert_select "h1", "Emergent Commons Volunteer App"

      assert_select "th", "Name"
      assert_select "th", "Greeter"
      assert_select "th", "Email"
      assert_select "th", "Status"
      assert_select "th.meeting", "Meeting Schedule\n\n(GMT)"
      assert_select "th", "Request Date"
      assert_select "th", "Answers"
      assert_select "th", "More"

      assert_select "td.user-name", user.name
      assert_select "td.user-greeter", user.greeter
      assert_select "td.user-email", user.email
      assert_select "td.user-status", user.status
      assert_select "td.user-meeting-datetime input[value=?]", user.welcome_timestamp.picker_datetime
      assert_select "td.user-request-date", user.request_timestamp.dow_short_date
      assert_select "td.user-questions.more i.bi-arrow-down-square", nil
      assert_select "td.user-notes.more i.bi-arrow-down-square", nil
      assert_select "tr.more td.user-notes-more textarea", user.notes
      
      user.questions_responses.split(" -:- ").each do |qna|
        q,a = *qna.split("\\")
        assert_select "tr.more td.user-questions-more li", "#{q}\n\n#{a}"
      end

      user.update(greeter: nil)
      get admin_users_path
      assert_select "td.user-greeter", "make me greeter!"
    end
  end
end
