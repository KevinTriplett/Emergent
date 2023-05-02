require "application_system_test_case"

class AdminUsersTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper
  DatabaseCleaner.clean

  test "User can get a magic link on first visit" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:greeter)
      visit logout_path
      assert_current_path root_path

      visit admin_users_path
      assert_current_path root_path

      ActionMailer::Base.deliveries.clear
      fill_in "Email or Full Name", with: user.email.upcase
      click_on "Send My Magic Link"
      # assert_selector ".flash", text: "Please be patient, it can take up to ten minutes to receive the link via EC chat and email (check your SPAM folder)"
      # email = ActionMailer::Base.deliveries.last
      # assert_equal email.to, [user.email]
      # assert_equal email.subject, "Emergent Commons - your magic link"
      # assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
      # assert_match /login\/#{user.token}/, email.body.inspect
      # ActionMailer::Base.deliveries.clear
      assert_current_path admin_users_path
      assert_nil ActionMailer::Base.deliveries.last
      click_link "Logout"
      assert_current_path root_path

      # ActionMailer::Base.deliveries.clear
      fill_in "Email or Full Name", with: user.name.downcase
      click_on "Send My Magic Link"
      # assert_selector ".flash", text: "Please be patient, it can take up to ten minutes to receive the link via EC chat and email (check your SPAM folder)"
      # email = ActionMailer::Base.deliveries.last
      # assert_equal email.to, [user.email]
      # assert_equal email.subject, "Emergent Commons - your magic link"
      # assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
      # assert_match /login\/#{user.token}/, email.body.inspect
      # ActionMailer::Base.deliveries.clear
      assert_current_path admin_users_path
      assert_nil ActionMailer::Base.deliveries.last
      click_link "Logout"
      assert_current_path root_path

      user.update email: ""
      ActionMailer::Base.deliveries.clear
      click_on "Send My Magic Link"
      assert_selector ".flash", text: "Please enter your Mighty Networks email address or name"
      assert_nil ActionMailer::Base.deliveries.last
      assert_current_path root_path

      garbage = "I like Pot Lucks"
      ActionMailer::Base.deliveries.clear
      fill_in "Email or Full Name", with: garbage
      click_on "Send My Magic Link"
      assert_selector ".flash", text: "Unable to find '#{garbage}' -- please try again"
      assert_nil ActionMailer::Base.deliveries.last
      assert_current_path root_path
    end
  end

  test "Greeter can select a user from index view then change status and see answers in show view" do
    DatabaseCleaner.cleaning do
      admin = login
      user = create_user(
        greeter_id: admin.id
      )
      user.update status: "Zoom Scheduled"
      user.update joined: true

      visit admin_user_path(token: user.token)
      assert_current_path admin_user_path(token: user.token)

      assert_selector "h2", text: user.name
      assert_selector ".user-greeter", text: admin.name
      assert_selector ".ui-selectmenu-text", text: "Zoom Scheduled"
      
      find(".ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: "Zoom Declined (completed)", exact_text: true).click
      assert_selector ".ui-selectmenu-text", text: "Zoom Declined (completed)"
      assert_equal "Zoom Declined (completed)", user.reload.status
      click_link "Show or Hide change log"
      assert_selector ".change-log", text: user.change_log.chomp

      visit admin_user_path(token: user.token)
      assert_current_path admin_user_path(token: user.token)

      assert_selector "a.user-back[href='#{admin_users_url}']", text: "👈 Back"
      assert_selector "a.user-profile-button[href='#{user.profile_url}']", text: "🙂 Profile"
      assert_selector "a.user-chat-button[href='#{user.chat_url}']", text: "💬 Chat"
      assert_selector ".user-greeter", text: admin.name
      assert_selector ".ui-selectmenu-text", text: "Zoom Declined (completed)"
      assert_no_selector ".questions-and-answers"
      # click_link "Show or Hide answers to questions"
      # assert_selector ".questions-and-answers"
    end
  end

  test "Greeter can do everything related to approval and greeting in wizard view" do
    DatabaseCleaner.cleaning do
      admin_1 = login
      admin_2 = create_user
      existing_user = create_user
      existing_user.update when_timestamp: nil

      visit admin_user_wizard_path(token: existing_user.token)
      assert_current_path admin_user_wizard_path(token: existing_user.token)

      ######################
      # GREETER
      assert_selector ".user-greeter a", text: "I want to greet"
      click_link("I want to greet")
      sleep 1
      existing_user.reload
      assert_equal admin_1.id, existing_user.greeter_id
      assert_selector ".user-greeter a", text: admin_1.name
      click_link "Show or Hide change log"
      page.find(".change-log").text.match /greeter changed: \(blank\) -> #{admin_1.name}/

      # check for ability to remove greeter
      message = dismiss_prompt do
        click_link(admin_1.name)
      end
      assert_equal "Remove yourself as greeter?", message
      existing_user.reload
      assert_equal admin_1.id, existing_user.greeter_id
      assert_selector ".user-greeter a", text: admin_1.name
      
      accept_prompt do
        click_link(admin_1.name)
      end
      sleep 1
      existing_user.reload
      assert_nil existing_user.greeter_id
      assert_selector ".user-greeter a", text: "I want to greet"

      # check when changing greeter
      existing_user.update(greeter_id: admin_2.id)
      visit admin_user_wizard_path(token: existing_user.token)
      assert_selector ".user-greeter a", text: admin_2.name

      click_link(admin_2.name)
      sleep 1
      existing_user.reload
      assert_equal admin_1.id, existing_user.greeter_id
      assert_selector ".user-greeter a", text: admin_1.name

      ####################
      ## APPROVE BUTTON
      visit admin_user_wizard_path(token: existing_user.token)
      assert_equal "Pending", existing_user.status
      assert_current_path admin_user_wizard_path(token: existing_user.token)
      assert_selector ".user-status", text: existing_user.status
      assert_selector ".user-greeter", text: admin_1.name
      assert_no_selector "input.email-subject"
      assert_no_selector "textarea.email-body"
      assert_no_selector ".email-template-buttons.greeting a.btn.btn-secondary", count: 5
      assert_no_selector "a.btn.btn-success", text: "Zoom Scheduled"
      assert_selector "form button.btn.btn-success.user-approve", text: "Answers Are Acceptable"
      assert_selector "a.btn.btn-warning.user-clarify", text: "Answers Need Clarification"
      assert_no_selector "a", text: "Decline This Request"

      click_link "Answers Need Clarification"

      assert_current_path admin_user_wizard_path(token: existing_user.token)
      assert_equal "Clarification Needed", existing_user.reload.status
      assert_selector ".user-status", text: existing_user.status
      assert_selector ".user-greeter", text: admin_1.name
      assert_selector "input.email-subject"
      assert_selector "textarea.email-body"
      assert_selector ".email-template-buttons.clarification a.btn.btn-secondary", count: 2
      assert_no_selector "a.btn.btn-success", text: "Zoom Scheduled"
      assert_selector "form button.btn.btn-success.user-approve", text: "Answers Are Acceptable"
      assert_no_selector "a", text: "Answers Need Clarification"
      assert_selector "a.btn.btn-danger.user-reject", text: "Decline This Request"

      old_status = existing_user.status
      message = dismiss_prompt do
        click_link "Decline This Request"
      end
      assert_equal "Have you asked a host to decline this request?", message
      existing_user.reload
      assert_equal old_status, existing_user.status

      accept_prompt do
        click_link "Decline This Request"
      end
      sleep 1
      assert_current_path admin_user_wizard_path(token: existing_user.token)
      assert_equal "Request Declined", existing_user.reload.status
      assert_selector ".user-status", text: existing_user.status
      assert_selector ".user-greeter", text: admin_1.name
      assert_no_selector "input.email-subject"
      assert_no_selector "textarea.email-body"
      assert_no_selector ".email-template-buttons.greeting a.btn.btn-secondary"
      assert_no_selector "a.btn.btn-success", text: "Zoom Scheduled"
      assert_no_selector "form button", text: "Answers Are Acceptable"
      assert_no_selector "a", text: "Answers Need Clarification"
      assert_no_selector "a", text: "Decline This Request"

      existing_user.update status: "Clarification Needed"
      visit admin_user_wizard_path(token: existing_user.token)
      assert_current_path admin_user_wizard_path(token: existing_user.token)

      click_on "Answers Are Acceptable"

      assert_current_path admin_user_wizard_path(token: existing_user.token)
      assert_selector ".flash", text: "User scheduled for approval, shouldn't take longer than ten minutes to be reflected in EC"
      assert_equal "Scheduling Zoom", existing_user.reload.status
      assert_selector ".user-status", text: existing_user.status
      assert_selector ".user-greeter", text: admin_1.name
      click_link "Compose Email"

      assert_selector "input.email-subject"
      assert_selector "textarea.email-body"
      assert_selector ".email-template-buttons.greeting a.btn.btn-secondary", count: 5
      assert_selector "a.btn.btn-success", text: "Zoom Scheduled"
      assert_no_selector "form button", text: "Answers Are Acceptable"
      assert_no_selector "a", text: "Answers Need Clarification"
      assert_no_selector "a", text: "Decline This Request"

      existing_user.update status: "Pending"
      existing_user.update joined: false
      visit admin_user_wizard_path(token: existing_user.token)
      assert_current_path admin_user_wizard_path(token: existing_user.token)

      click_on "Answers Are Acceptable"
      existing_user.update joined: true

      assert_current_path admin_user_wizard_path(token: existing_user.token)
      assert_equal "Scheduling Zoom", existing_user.reload.status
      click_link "Compose Email"

      assert find("input.email-subject").value.blank?
      assert find("textarea.email-body").value.blank?
      assert_selector "a.email-send", text: "Launch Chosen Email Client"
      click_link "Template 2"
      assert find("input.email-subject").value
      assert find("textarea.email-body").value
      assert_selector "a.email-send", text: "Launch Chosen Email Client"

      click_link "Launch Chosen Email Client"

      visit admin_user_wizard_path(token: existing_user.token)
      assert_current_path admin_user_wizard_path(token: existing_user.token)
      assert_equal "Scheduling Zoom", existing_user.reload.status
      assert_selector ".user-status", text: existing_user.status
      assert_selector ".user-greeter", text: admin_1.name
      click_link "Compose Email"

      assert_selector "input.email-subject"
      assert_selector "textarea.email-body"
      assert_selector ".email-template-buttons.greeting a.btn.btn-secondary", count: 6
      assert_selector ".email-template-buttons.greeting a.btn.btn-secondary", text: "Your Most Recent Email"
      assert_selector "a.btn.btn-success", text: "Zoom Scheduled"
      assert_no_selector "form button", text: "Answers Are Acceptable"
      assert_no_selector "a", text: "Answers Need Clarification"
      assert_no_selector "a", text: "Decline This Request"
      click_link "Enter Greeting Date"

      assert_current_path admin_user_wizard_path(token: existing_user.token)
      assert_equal "Scheduling Zoom", existing_user.reload.status
      assert_selector ".user-status", text: existing_user.status
      assert_selector ".user-greeter", text: admin_1.name
      assert_no_selector "input.email-subject"
      assert_no_selector "textarea.email-body"
      assert_no_selector ".email-template-buttons.greeting a.btn.btn-secondary"
      assert_no_selector "a.btn.btn-success", text: "Zoom Scheduled"
      assert_no_selector "form button", text: "Answers Are Acceptable"
      assert_no_selector "a", text: "Answers Need Clarification"
      assert_no_selector "a", text: "Decline This Request"

      assert_selector ".user-meeting-datetime input.datetime-picker"
      input = find(".user-meeting-datetime input.datetime-picker")
      input.click
      input.send_keys("2022-10-09 15:45")
      input.send_keys [:enter]
      message = dismiss_prompt
      assert_equal "Are you sure you want to set the Zoom meeting in the past?", message
      assert_selector ".user-meeting-datetime input", text: ""
      sleep 1
      assert_nil existing_user.reload.when_timestamp

      input.click
      input.send_keys("2023-10-09 15:45")
      input.send_keys [:escape]
      sleep 2 # cannot be 1 for some reason...
      assert_equal "2023-10-09T19:45:00Z", existing_user.reload.when_timestamp.picker_datetime

      # check date format in index view
      visit admin_users_path
      assert_selector ".user-meeting-datetime", text: "2023-Oct-9 @ 3:45 PM"
      visit admin_user_wizard_path(token: existing_user.token)
      click_link "Enter Greeting Date"

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

  test "Greeter can update user status in show view" do
    DatabaseCleaner.cleaning do
      admin = login
      existing_user = create_user
      existing_user.update status: "Scheduling Zoom"

      visit admin_user_path(token: existing_user.token)
      assert_current_path admin_user_path(token: existing_user.token)

      find(".ui-selectmenu-text").click
      find(".ui-menu-item-wrapper", text: "Zoom Scheduled", exact_text: true).click
      sleep 1

      assert_selector ".ui-selectmenu-text", text: "Zoom Scheduled"
      assert_equal "Zoom Scheduled", existing_user.reload.status
    end
  end

  test "Greeter can enter notes in show view" do
    DatabaseCleaner.cleaning do
      user = login
      user.update status: "Zoom Done (completed)"
      user.update joined: true
      old_notes = user.notes

      visit admin_user_path(token: user.token)
      assert_current_path admin_user_path(token: user.token)

      # find("td.user-notes.more i").click -- do not have to click if notes is <> ""
      notes_css = ".user-notes textarea"
      assert_selector notes_css, text: old_notes

      keys = " hello this is new notes"
      find(notes_css).send_keys(keys)
      sleep 2
      user.reload
      assert_equal old_notes + keys, user.notes
      assert_selector ".user-notes span", text: "saved"
      click_link "Show or Hide change log"
      page.find(".change-log").text.match /notes changed: this are notes -> this are notes hello this is new notes/

      keys = " hello this is more stuff"
      find(notes_css).send_keys(keys)
      assert_selector ".user-notes span", text: ""

      keys = ""
      100.times {|i| keys += i.to_s}
      find(notes_css).send_keys(keys)
      sleep 2
      page.find(".change-log").text.match /notes changed: this are notes hello this is new notes hello this is more stuff -> (too long)/
    end
  end

  test "Greeter can sort members in index view" do
    DatabaseCleaner.cleaning do
      old_request_timestamp = (Time.now-365.days).strftime("%Y-%m-%dT%H:%M:%SZ")
      admin = login
      admin.update request_timestamp: old_request_timestamp
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
      admin = login
      admin.update name: random_user_name
      admin.update request_timestamp: old_time
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
