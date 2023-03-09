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
      fill_in "Email or Full Name", with: user.email.upcase
      click_on "Send My Magic Link"
      assert_selector ".flash", text: "Magic link sent, check your email SPAM folder and your Emergent Commons chat channel"
      email = ActionMailer::Base.deliveries.last
      assert_equal email.to, [user.email]
      assert_equal email.subject, "Emergent Commons - your magic link"
      assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
      assert_match /login\/#{user.token}/, email.body.inspect
      ActionMailer::Base.deliveries.clear

      ActionMailer::Base.deliveries.clear
      fill_in "Email or Full Name", with: user.name.downcase
      click_on "Send My Magic Link"
      assert_selector ".flash", text: "Magic link sent, check your email SPAM folder and your Emergent Commons chat channel"
      email = ActionMailer::Base.deliveries.last
      assert_equal email.to, [user.email]
      assert_equal email.subject, "Emergent Commons - your magic link"
      assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
      assert_match /login\/#{user.token}/, email.body.inspect
      ActionMailer::Base.deliveries.clear

      user.update email: ""
      ActionMailer::Base.deliveries.clear
      click_on "Send My Magic Link"
      assert_selector ".flash", text: "Please enter your Mighty Networks email address or name"
      assert_nil ActionMailer::Base.deliveries.last
      ActionMailer::Base.deliveries.clear

      garbage = "I like Pot Lucks"
      ActionMailer::Base.deliveries.clear
      fill_in "Email or Full Name", with: garbage
      click_on "Send My Magic Link"
      assert_selector ".flash", text: "Unable to find '#{garbage}' -- please try again"
      assert_nil ActionMailer::Base.deliveries.last
      ActionMailer::Base.deliveries.clear
    end
  end

  test "Greeter can select a user from index view then change greeter and shadow in show view" do
    DatabaseCleaner.cleaning do
      admin = login
      admin2 = create_user
      admin3 = create_user
      user = create_user

      visit admin_user_path(token: user.token)
      assert_current_path admin_user_path(token: user.token)

      assert_selector "h3", text: user.name
      
      assert_selector "a.user-back[href='#{admin_users_url}']", text: "👈 Back"
      assert_selector "a.user-profile-button[href='#{user.profile_url}']", text: "🙂 Profile"
      assert_selector "a.user-chat-button[href='#{user.chat_url}']", text: "💬 Chat"

      assert_selector "td.user-greeter a", text: "I want to greet"
      assert_selector "td.user-shadow a", text: "I want to shadow"

      ######################
      # GREETER
      click_link('I want to greet')
      sleep 1
      user.reload
      assert_equal admin.name, user.greeter.name
      assert_selector "td.user-greeter a", text: admin.name
      page.find("td.change-log").text.match /greeter changed: \(blank\) -> #{admin.name}/

      # check when removing greeter
      message = dismiss_prompt do
        click_link(admin.name)
      end
      assert_equal "Remove yourself as greeter?", message
      user.reload
      assert_equal admin.id, user.greeter_id
      assert_selector "td.user-greeter a", text: admin.name
      
      accept_prompt do
        click_link(admin.name)
      end
      sleep 1
      user.reload
      assert_nil user.greeter_id
      assert_selector "td.user-greeter a", text: "I want to greet"

      # check when changing greeter
      user.update(greeter_id: admin2.id)
      visit admin_user_path(token: user.token)
      assert_selector "td.user-greeter a", text: admin2.name

      click_link(admin2.name)
      sleep 1
      user.reload
      assert_equal admin.id, user.greeter_id
      assert_selector "td.user-greeter a", text: admin.name

      # clean up
      user.update(greeter_id: nil)
      visit admin_user_path(token: user.token)

      ######################
      # SHADOW
      click_link('I want to shadow')
      sleep 1
      user.reload
      assert_equal admin.id, user.shadow_greeter.id
      assert_selector "td.user-shadow a", text: admin.name
      page.find("td.change-log").text.match /shadow_greeter changed: \(blank\) -> #{admin.name}/

      # check when removing shadow greeter
      message = dismiss_prompt do
        click_link(admin.name)
      end
      assert_equal "Remove yourself as shadow greeter?", message
      user.reload
      assert_equal admin.id, user.shadow_greeter_id
      assert_selector "td.user-shadow a", text: admin.name
      
      accept_prompt do
        click_link(admin.name)
      end
      sleep 1
      user.reload
      assert_nil user.shadow_greeter_id
      assert_selector "td.user-shadow a", text: "I want to shadow"

      # check when changing greeter
      user.update(shadow_greeter_id: admin3.id)
      visit admin_user_path(token: user.token)
      assert_selector "td.user-shadow a", text: admin3.name

      message = dismiss_prompt do
        click_link(admin3.name)
      end
      assert_equal "You will be the shadow greeter instead?\n(we prefer only one shadow greeter)", message
      user.reload
      assert_equal admin3.id, user.shadow_greeter_id
      assert_selector "td.user-shadow a", text: admin3.name
      
      accept_prompt do
        click_link(admin3.name)
      end
      sleep 1
      user.reload
      assert_equal admin.id, user.shadow_greeter_id
      assert_selector "td.user-shadow a", text: admin.name
    end
  end

  test "Greeter can change user status and set meeting in show view" do
    DatabaseCleaner.cleaning do
      admin = login
      existing_user = create_user
      assert existing_user.when_timestamp

      visit admin_user_path(token: existing_user.token)
      assert_current_path admin_user_path(token: existing_user.token)

      ####################
      ## APPROVE BUTTON
      assert !existing_user.joined
      assert_equal "Pending", existing_user.status
      assert_selector "a.btn.btn-primary.user-approve", text: "Approve"

      existing_user.update(status: "Request Declined")
      visit admin_user_path(token: existing_user.token)
      assert_selector ".ui-selectmenu-text", text: existing_user.status
      assert_no_selector "a.btn.btn-primary.user-approve", text: "Approve"

      existing_user.update(status: "Scheduling Zoom")
      existing_user.update(joined: true)
      visit admin_user_path(token: existing_user.token)
      assert_selector ".ui-selectmenu-text", text: existing_user.status
      assert_no_selector "a.btn.btn-primary.user-approve", text: "Approve"

      ####################
      ## STATUS AND MEETING DATE
      # assert_selector ".user-meeting-datetime", text: "2022-Dec-7 @ 3:30 AM"

      find(".ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: "Zoom Scheduled", exact_text: true).click
      sleep 1

      assert_selector ".ui-selectmenu-text", text: "Zoom Scheduled"
      assert_no_selector "a.btn.btn-primary.user-approve", text: "Approve"
      assert_equal "Zoom Scheduled", existing_user.reload.status
      assert_selector ".user-meeting-datetime", text: ""
      assert_nil existing_user.reload.when_timestamp

      existing_user.update(when_timestamp: "2023 Jan 20 10:00")
      find(".ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: "Zoom Done (completed)", exact_text: true).click
      assert_selector ".ui-selectmenu-text", text: "Zoom Done (completed)"
      assert_no_selector "a.btn.btn-primary.user-approve", text: "Approve"
      assert_equal "Zoom Done (completed)", existing_user.reload.status
      assert_nil existing_user.when_timestamp

      assert_selector "td.change-log", text: existing_user.change_log.chomp
      visit admin_user_path(token: existing_user.token)

      ####################
      ## MEETING
      input = find("td.user-meeting-datetime input.datetime-picker")
      input.click
      find(".ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: "Scheduling Zoom", exact_text: true).click

      input.click
      input.send_keys("2022-10-09 15:45")
      input.send_keys [:enter]
      message = dismiss_prompt
      assert_equal "Are you sure you want to set the Zoom meeting in the past?", message
      assert_selector "td.user-meeting-datetime input", text: ""
      sleep 1
      assert_nil existing_user.reload.when_timestamp

      input.click
      input.send_keys("2023-10-09 15:45")
      input.send_keys [:escape]
      sleep 2 # cannot be 1 for some reason...
      assert_equal "2023-10-09T19:45:00Z", existing_user.reload.when_timestamp.picker_datetime
      assert_selector "td.change-log", text: existing_user.change_log.chomp

      # check date format in index view
      visit admin_users_path
      assert_selector ".user-meeting-datetime", text: "2023-Oct-9 @ 3:45 PM"
      visit admin_user_path(token: existing_user.token)

      # now check ability to delete
      input.click
      input.value.length.times { input.send_keys [:arrow_right] }
      input.value.length.times { input.send_keys [:backspace] }
      input.send_keys [:escape]
      sleep 2
      existing_user.reload
      assert_nil existing_user.when_timestamp
    end
  end

  test "Greeter can enter notes in show view" do
    DatabaseCleaner.cleaning do
      user = login
      old_notes = user.notes

      visit admin_user_path(token: user.token)
      assert_current_path admin_user_path(token: user.token)

      # find("td.user-notes.more i").click -- do not have to click if notes is <> ""
      notes_css = "td.user-notes textarea"
      assert_selector notes_css, text: old_notes

      keys = " hello this is new notes"
      find(notes_css).send_keys(keys)
      sleep 2
      user.reload
      assert_equal old_notes + keys, user.notes
      assert_selector "td.user-notes span", text: "saved"
      page.find("td.change-log").text.match /notes changed: this are notes -> this are notes hello this is new notes/

      keys = " hello this is more stuff"
      find(notes_css).send_keys(keys)
      assert_selector "td.user-notes span", text: ""

      keys = ""
      100.times {|i| keys += i.to_s}
      find(notes_css).send_keys(keys)
      sleep 2
      page.find("td.change-log").text.match /notes changed: this are notes hello this is new notes hello this is more stuff -> (too long)/
    end
  end

  test "Greeter can send email in show view" do
    DatabaseCleaner.cleaning do
      admin = login
      existing_user = create_user
      old_status = existing_user.status

      visit admin_user_path(token: existing_user.token)
      assert_current_path admin_user_path(token: existing_user.token)

      accept_prompt(with: "0") do
        click_link(existing_user.email)
      end
      message = accept_alert
      assert_equal "Choose an email template 1 through 5", message
      assert_equal old_status, existing_user.status

      accept_prompt(with: "6") do
        click_link(existing_user.email)
      end
      message = accept_alert
      assert_equal "Choose an email template 1 through 5", message
      assert_equal old_status, existing_user.status
    end
  end

  test "Greeter can sort members in index view" do
    DatabaseCleaner.cleaning do
      old_request_timestamp = (Time.now-365.days).strftime("%Y-%m-%dT%H:%M:%SZ")
      admin = login(request_timestamp: old_request_timestamp)
      other_greeter = create_user(request_timestamp: old_request_timestamp)

      user1 = create_user({
        name: "A B",
        request_timestamp: (Time.now-3.days).strftime("%Y-%m-%dT%H:%M:%SZ"),
        status: "Scheduling Zoom",
        greeter_id: other_greeter.id
      })
      user2 = create_user({
        name: "A C",
        request_timestamp: (Time.now-1.days).strftime("%Y-%m-%dT%H:%M:%SZ"),
        status: "Pending",
        greeter_id: nil
      })
      user3 = create_user({
        name: "A D",
        request_timestamp: (Time.now-2.days).strftime("%Y-%m-%dT%H:%M:%SZ"),
        status: "Scheduling Zoom",
        greeter_id: admin.id
      })

      visit admin_users_path
      assert_current_path admin_users_path

      page.find("input#show-all-greetings").click

      assert_equal page.all(".user-name").collect(&:text), [user2.name, user3.name, user1.name]
      page.find("th.name").click
      assert_equal page.all(".user-name").collect(&:text), [user1.name, user2.name, user3.name]
      page.find("th.name").click
      assert_equal page.all(".user-name").collect(&:text), [user3.name, user2.name, user1.name]

      assert_equal 3, page.all("tbody tr", visible: true).count
      page.find("input#show-all-greetings").click
      assert_equal 2, page.all("tbody tr", visible: true).count
      page.find("input#show-all-greetings").click
      assert_equal 3, page.all("tbody tr", visible: true).count
    end
  end

  test "Greeter can search for members" do
    DatabaseCleaner.cleaning do
      old_time = (Time.now-365.days).strftime("%Y-%m-%dT%H:%M:%SZ")
      admin = login({
        name: random_user_name,
        request_timestamp: old_time
      })
      user1 = create_user({
        name: "Jote Bloow",
        request_timestamp: (Time.now-7.days).strftime("%Y-%m-%dT%H:%M:%SZ")
      })
      user2 = create_user({
        name: "Jaean Dove",
        request_timestamp: (Time.now-8.days).strftime("%Y-%m-%dT%H:%M:%SZ"),
        status: "Pending"
      })
      user3 = create_user({
        name: "Pati Ritte",
        request_timestamp: (Time.now-9.days).strftime("%Y-%m-%dT%H:%M:%SZ")
      })
      user4 = create_user({
        name: "Tiomthy Barttun",
        request_timestamp: old_time,
        status: "Zoom Done (completed)"
      })
      user2_first_name = user2.name.split(" ")[0]

      visit admin_users_path
      assert_current_path admin_users_path
      assert_equal page.all(".user-name").collect(&:text), [user1.name, user2.name, user3.name]

      input = page.find("input[type='search']")
      input.click
      input.send_keys(user2_first_name)
      assert_equal page.all(".user-name").collect(&:text), [user2.name]
      find("td.user-name").click
      assert_current_path admin_user_wizard_path(token: user2.token)

      visit admin_users_path

      input.click
      user2_first_name.length.times { input.send_keys [:backspace] }
      input.send_keys("Tio")
      sleep 1
      assert_equal page.all(".user-name").collect(&:text), [user4.name]
      find("td.user-name").click
      assert_current_path admin_user_path(token: user4.token)
    end
  end
end
