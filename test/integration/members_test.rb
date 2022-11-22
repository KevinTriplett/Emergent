require "test_helper"

class UserFlowTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Puppy!" do
    get "/"
    assert_select "p", "COming SoON!\n\n(ask a volunteer how to use this app)"
  end
end
