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
      user.update(greeter: nil)

      get admin_users_path
      
      assert_select "h5", "Existing Members"
      assert_select "h1", "Emergent Commons Volunteer App"

      assert_select "th", "Name"
      assert_select "th", "Greeter"
      assert_select "th", "Email"
      assert_select "th", "Status"
      assert_select "th", "Request Date"
      assert_select "th", "Answers"
      assert_select "th", "More"

      assert_select "td.member-name", user.name
      assert_select "td.member-greeter", user.greeter
      assert_select "td.member-email", user.email
      assert_select "td.member-status", user.status
      assert_select "td.member-request-date", user.request_timestamp.dow_short_date
      assert_select "td.member-questions.more i.bi-arrow-down-square", nil
      assert_select "td.member-actions.more i.bi-arrow-down-square", nil
      assert_select "tr.more td.member-notes-more p", user.notes
      
      user.questions_responses.split(" -:- ").each do |qna|
        q,a = *qna.split("\\")
        assert_select "tr.more td.member-questions-more li", "Question: #{q}\n\nAnswer: #{a}"
      end

      user.update(greeter: nil)
      get admin_users_path
      assert_select "td.member-greeter", "make me greeter!"
    end
  end
end
