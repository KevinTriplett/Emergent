require "application_system_test_case"

class AdminUsersTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "Saves greeter name between prompts and page loads" do
    DatabaseCleaner.cleaning do
      user = create_user

      visit admin_users_path
      assert_current_path admin_users_path

      accept_prompt(with: random_user_name) do
        click_link('make me greeter!')
      end
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter

      user.update!(greeter: nil)
      visit admin_users_path
      assert_current_path admin_users_path
      accept_prompt do
        click_link('make me greeter!')
      end
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter
      user.update!(greeter: nil)

      visit root_path
      visit admin_users_path
      assert_current_path admin_users_path

      accept_prompt do
        click_link('make me greeter!')
      end
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter
    end
  end

  test "Greeter can select a user to greet" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_name = user.name

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

      accept_prompt(with: random_user_name) do
        click_link('make me greeter!')
      end
      
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter
    end
  end

  test "Greeter can change user status" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_status = user.status

      visit admin_users_path
      assert_current_path admin_users_path

      assert_selector "td.user-status a", text: user.status

      message = dismiss_prompt do
        click_link(user.status)
      end
      assert_equal "Enter new status", message
      
      sleep 1
      user.reload
      assert_equal old_status, user.status

      new_status = "panic"
      accept_prompt(with: new_status) do
        click_link(user.status)
      end

      sleep 1
      user.reload
      assert_equal new_status, user.status
    end
  end

  test "Greeter can change meeting datetime" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_meeting = user.welcome_timestamp.short_date_at_time

      visit admin_users_path
      assert_current_path admin_users_path

      assert_selector "td.user-meeting-datetime a", text: old_meeting

      message = dismiss_prompt do
        click_link(old_meeting)
      end
      assert_equal "Enter local time and date like Jan 12, 2023 3PM", message
      
      sleep 1
      user.reload
      assert_equal old_meeting, user.welcome_timestamp.short_date_at_time

      new_datetime = "Jan 12, 2023 3PM"
      accept_prompt(with: new_datetime) do
        click_link(old_meeting)
      end

      sleep 1
      user.reload
      assert_equal new_datetime.to_time, user.welcome_timestamp
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

      keys = " hello this is new notes"
      find(notes_css).send_keys(keys)
      sleep 2
      user.reload
      assert_equal old_notes + keys, user.notes
    end
  end

  test "Greeter can send email and it automatically changes status" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_status = user.status

      visit admin_users_path
      assert_current_path admin_users_path

      message = accept_alert do
        click_link(user.email)
      end
      assert_equal "First, click 'make me greeter!' and then send the email", message
      user.reload
      assert_nil user.greeter
      assert_equal old_status, user.status

      accept_prompt(with: random_user_name) do
        click_link('make me greeter!')
      end
      sleep 1
    
      message = dismiss_prompt do
        click_link(user.email)
      end
      assert_equal "Enter an email template 1 through 4", message
      user.reload
      assert_equal old_status, user.status
      
      accept_prompt(with: "0") do
        click_link(user.email)
      end
      message = accept_alert
      assert_equal "Choose an email template 1 through 4", message
      assert_equal old_status, user.status
      
      accept_prompt(with: "5") do
        click_link(user.email)
      end
      message = accept_alert
      assert_equal "Choose an email template 1 through 4", message
      assert_equal old_status, user.status
      
      accept_prompt(with: "1") do
        click_link(user.email)
      end
      sleep 1
      user.reload
      assert_equal "Invite Sent", user.status
    end
  end
end
