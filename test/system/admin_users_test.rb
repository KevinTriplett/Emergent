require "application_system_test_case"

class AdminUsersTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "Greeter can select a user to greet" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_name = user.name
      old_status = user.status

      visit admin_users_path
      assert_current_path admin_users_path

      assert_selector "td.user-name a", text: user.name
      assert_selector "td.user-greeter a", text: "make me greeter!"

      message = dismiss_prompt do
        click_link('make me greeter!')
      end
      assert_equal "Enter your name", message
      
      sleep 1
      user.reload
      assert_equal old_name, user.name

      message = accept_prompt(with: random_user_name) do
        click_link('make me greeter!')
      end
      
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter

      message = dismiss_prompt do
        click_link(user.status)
      end
      assert_equal "Enter new status", message
      
      sleep 1
      user.reload
      assert_equal old_status, user.status

      new_status = "panic"
      message = accept_prompt(with: new_status) do
        click_link(user.status)
      end

      sleep 1
      user.reload
      assert_equal new_status, user.status
    end
  end

  test "Greeter can enter notes" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_notes = user.notes

      visit admin_users_path
      assert_current_path admin_users_path

      find("td.user-notes.more i").click
      notes_css = "tr.more td.user-notes-more textarea"
      assert_selector notes_css, text: old_notes

      keys = "hello this is new notes"
      find(notes_css).send_keys(keys)
      sleep 2
      user.reload
      assert_equal old_notes + keys, user.notes
    end
  end
end
