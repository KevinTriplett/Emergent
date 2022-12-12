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
        click_link('Make me greeter!')
      end
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter

      user.update!(greeter: nil)
      visit admin_users_path
      assert_current_path admin_users_path
      accept_prompt do
        click_link('Make me greeter!')
      end
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter
      user.update!(greeter: nil)

      visit root_path
      visit admin_users_path
      assert_current_path admin_users_path

      accept_prompt do
        click_link('Make me greeter!')
      end
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter
    end
  end

  test "Greeter can select a user to greet and shadow in show view" do
    DatabaseCleaner.cleaning do
      user = create_user

      visit admin_user_path(user.id)
      assert_current_path admin_user_path(user.id)

      assert_selector "h3", text: user.name
      
      assert_selector "a.user-back[href='#{admin_users_url}']", text: "👈 Back"
      assert_selector "a.user-profile-button[href='#{user.profile_url}']", text: "😊 Profile"
      assert_selector "a.user-chat-button[href='#{user.chat_url}']", text: "💬 Chat"

      assert_selector "td.user-greeter a", text: "Make me greeter!"
      assert_selector "td.user-shadow a", text: "I will shadow!"

      ######################
      # GREETER
      message = dismiss_prompt do
        click_link('Make me greeter!')
      end
      assert_equal "Enter your name", message
      
      sleep 1
      user.reload
      assert_nil user.greeter

      accept_prompt(with: random_user_name) do
        click_link('Make me greeter!')
      end
      
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter

      accept_prompt(with: "") do
        click_link(last_random_user_name)
      end
      
      sleep 1
      user.reload
      assert_nil user.greeter
      assert_selector "td.user-greeter a", text: "Make me greeter!"

      ######################
      # SHADOW
      message = dismiss_prompt do
        click_link('I will shadow!')
      end
      assert_equal "Enter your name", message
      
      sleep 1
      user.reload
      assert_nil user.shadow_greeter

      accept_prompt(with: random_user_name) do
        click_link('I will shadow!')
      end
      
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.shadow_greeter

      accept_prompt(with: "") do
        click_link(last_random_user_name)
      end
      
      sleep 1
      user.reload
      assert_nil user.shadow_greeter
      assert_selector "td.user-shadow a", text: "I will shadow!"
    end
  end

  test "Greeter can select a user to greet in index view" do
    DatabaseCleaner.cleaning do
      user = create_user

      visit admin_users_path
      assert_current_path admin_users_path

      assert_selector "td.user-name a", text: user.name
      assert_selector "td.user-greeter a", text: "Make me greeter!"
      assert_selector "td.user-shadow a", text: "I will shadow!"

      ######################
      # GREETER
      message = dismiss_prompt do
        click_link('Make me greeter!')
      end
      assert_equal "Enter your name", message
      
      sleep 1
      user.reload
      assert_nil user.greeter

      accept_prompt(with: random_user_name) do
        click_link('Make me greeter!')
      end
      
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.greeter

      accept_prompt(with: "") do
        click_link(last_random_user_name)
      end
      
      sleep 1
      user.reload
      assert_nil user.greeter
      assert_selector "td.user-greeter a", text: "Make me greeter!"

      ######################
      # SHADOW
      message = dismiss_prompt do
        click_link('I will shadow!')
      end
      assert_equal "Enter your name", message
      
      sleep 1
      user.reload
      assert_nil user.shadow_greeter

      accept_prompt(with: random_user_name) do
        click_link('I will shadow!')
      end
      
      sleep 1
      user.reload
      assert_equal last_random_user_name, user.shadow_greeter

      accept_prompt(with: "") do
        click_link(last_random_user_name)
      end
      
      sleep 1
      user.reload
      assert_nil user.shadow_greeter
      assert_selector "td.user-shadow a", text: "I will shadow!"
    end
  end

  test "Greeter can change user status and set meeting in show view" do
    DatabaseCleaner.cleaning do
      user = create_user(status: "Joined!")
      user.update!(welcome_timestamp: nil)

      visit admin_user_path(user.id)
      assert_current_path admin_user_path(user.id)

      ####################
      ## STATUS
      assert_selector "td.user-status span.ui-selectmenu-text", text: user.status

      find("td.user-status span.ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: "Pending", exact_text: true).click
      assert_selector "td.user-status span.ui-selectmenu-text", text: "Pending"

      sleep 1
      user.reload
      assert_equal "Pending", user.status
      old_status = user.status

      ####################
      ## MEETING
      assert_nil user.welcome_timestamp
      input = find("td.user-meeting-datetime input.datetime-picker")
      input.click
      input.send_keys("2023-10-09 15:45")
      input.send_keys [:escape]
      sleep 2
      user.reload
      assert_equal "2023-10-09T20:45:00Z", user.welcome_timestamp.picker_datetime
      input.send_keys [:escape]

      input.click
      input.value.length.times { input.send_keys [:arrow_right] }
      input.value.length.times { input.send_keys [:backspace] }
      input.send_keys [:escape]
      sleep 2
      user.reload
      assert_nil user.welcome_timestamp
      assert_equal old_status, user.status
    end
  end

  test "Greeter can change user status and change meeting in index view" do
    DatabaseCleaner.cleaning do
      user = create_user(status: "Joined!")
      user.update!(welcome_timestamp: nil)

      visit admin_users_path
      assert_current_path admin_users_path

      ####################
      ## STATUS
      assert_selector "td.user-status span.ui-selectmenu-text", text: user.status

      find("td.user-status span.ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: "Completed", exact_text: true).click
      assert_selector "td.user-status span.ui-selectmenu-text", text: "Completed"

      sleep 1
      user.reload
      assert_equal "Completed", user.status
      old_status = user.status

      ####################
      ## MEETING
      assert_nil user.welcome_timestamp
      input = find("td.user-meeting-datetime input.datetime-picker")
      input.click
      input.send_keys("2023-10-09 15:45")
      input.send_keys [:escape]
      sleep 2
      user.reload
      assert_equal "2023-10-09T20:45:00Z", user.welcome_timestamp.picker_datetime
      input.send_keys [:escape]

      input.click
      input.value.length.times { input.send_keys [:arrow_right] }
      input.value.length.times { input.send_keys [:backspace] }
      input.send_keys [:escape]
      sleep 2
      user.reload
      assert_nil user.welcome_timestamp
      assert_equal old_status, user.status
    end
  end

  test "Greeter can enter notes in show view" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_notes = user.notes

      visit admin_user_path(user.id)
      assert_current_path admin_user_path(user.id)

      # find("td.user-notes.more i").click -- do not have to click if notes is <> ""
      notes_css = "td.user-notes textarea"
      assert_selector notes_css, text: old_notes

      keys = " hello this is new notes"
      find(notes_css).send_keys(keys)
      sleep 2
      user.reload
      assert_equal old_notes + keys, user.notes
      assert_selector "td.user-notes span", text: "saved"

      keys = " hello this is more stuff"
      find(notes_css).send_keys(keys)
      assert_selector "td.user-notes span", text: ""
    end
  end

  test "Greeter can send email in show view" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_status = user.status

      visit admin_user_path(user.id)
      assert_current_path admin_user_path(user.id)

      message = accept_alert do
        click_link(user.email)
      end
      assert_equal "First, click 'Make me greeter!' and then send the email", message
      user.reload
      assert_nil user.greeter
      assert_equal old_status, user.status

      accept_prompt(with: random_user_name) do
        click_link('Make me greeter!')
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
    end
  end

  test "Greeter can send email in index view" do
    DatabaseCleaner.cleaning do
      user = create_user
      old_status = user.status

      visit admin_users_path
      assert_current_path admin_users_path

      message = accept_alert do
        click_link(user.email)
      end
      assert_equal "First, click 'Make me greeter!' and then send the email", message
      user.reload
      assert_nil user.greeter
      assert_equal old_status, user.status

      accept_prompt(with: random_user_name) do
        click_link('Make me greeter!')
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
    end
  end
end
