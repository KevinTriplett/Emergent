require "application_system_test_case"

class UserTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean


  test "User can reach their dashboard" do
    DatabaseCleaner.cleaning do
      user = login
      visit root_url
      assert_current_path user_url(user.token)

      assert_selector "h5", text: user.name
    end
  end
end
