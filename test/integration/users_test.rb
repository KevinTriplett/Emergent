require "test_helper"

class UserFlowTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Sign in page!" do
    get "/"
    assert_response :success
    assert_select "input[name='email']", ""
    assert_select "button", "Send My Magic Link"
  end
end
