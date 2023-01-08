require "application_system_test_case"

class AdminUsersTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean


  test "User can get a magic link on first visit" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      visit logout_path
      assert_current_path root_path

      visit admin_users_path
      assert_current_path root_path

      ActionMailer::Base.deliveries.clear
      fill_in "Email", with: user.email
      click_on "Send My Magic Link"
      email = ActionMailer::Base.deliveries.last
      assert_equal email.to, [user.email]
      assert_equal email.subject, "Emergent Commons - your magic link"
      assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
      assert_match /#{get_magic_link(user)}/, email.body.inspect
      ActionMailer::Base.deliveries.clear
    end
  end

  test "Greeter can select a user to greet and shadow in show view" do
    DatabaseCleaner.cleaning do
      admin = login
      user = create_user

      visit admin_user_path(user.id)
      assert_current_path admin_user_path(user.id)

      assert_selector "h3", text: user.name
      
      assert_selector "a.user-back[href='#{admin_users_url}']", text: "👈 Back"
      assert_selector "a.user-profile-button[href='#{user.profile_url}']", text: "🙂 Profile"
      assert_selector "a.user-chat-button[href='#{user.chat_url}']", text: "💬 Chat"

      assert_selector "td.user-greeter a", text: "I will greet"
      assert_selector "td.user-shadow a", text: "I will shadow"

      ######################
      # GREETER
      click_link('I will greet')
      sleep 1
      user.reload
      assert_equal admin.name, user.greeter.name

      ######################
      # SHADOW
      click_link('I will shadow')
      sleep 1
      user.reload
      assert_equal admin.name, user.shadow_greeter.name
    end
  end

  test "Greeter can change user status and set meeting in show view" do
    DatabaseCleaner.cleaning do
      user = login(status: "Joined!")
      user.update!(when_timestamp: nil)

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

      assert_selector "td.change-log", text: user.change_log.chomp

      ####################
      ## MEETING
      assert_nil user.when_timestamp
      input = find("td.user-meeting-datetime input.datetime-picker")
      input.click
      input.send_keys("2023-10-09 15:45")
      input.send_keys [:escape]
      sleep 2
      user.reload
      assert_equal "2023-10-09T20:45:00Z", user.when_timestamp.picker_datetime
      input.send_keys [:escape]

      input.click
      input.value.length.times { input.send_keys [:arrow_right] }
      input.value.length.times { input.send_keys [:backspace] }
      input.send_keys [:escape]
      sleep 2
      user.reload
      assert_nil user.when_timestamp
      assert_equal old_status, user.status
    end
  end

  test "Greeter can enter notes in show view" do
    DatabaseCleaner.cleaning do
      user = login
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
      user = login
      old_status = user.status

      visit admin_user_path(user.id)
      assert_current_path admin_user_path(user.id)

      message = dismiss_prompt do
        click_link(user.email)
      end
      assert_equal "Enter an email template 1 through 5", message
      user.reload
      assert_equal old_status, user.status
      
      accept_prompt(with: "0") do
        click_link(user.email)
      end
      message = accept_alert
      assert_equal "Choose an email template 1 through 5", message
      assert_equal old_status, user.status
      
      accept_prompt(with: "6") do
        click_link(user.email)
      end
      message = accept_alert
      assert_equal "Choose an email template 1 through 5", message
      assert_equal old_status, user.status
    end
  end

  test "Greeter can sort members in index view" do
    DatabaseCleaner.cleaning do
      user1 = login(name: "A B", request_timestamp: Time.now-3.days)
      user2 = create_user(name: "A C", request_timestamp: Time.now-2.days)
      user3 = create_user(name: "A D", request_timestamp: Time.now-1.days)
      puts "user2 = #{user2.inspect}"

      visit admin_users_path
      assert_current_path admin_users_path

      assert_equal page.all(".user-name").collect(&:text), [user3.name, user2.name, user1.name]
    end
  end
end
