# require "application_system_test_case"

# class AdminUsersTest < ApplicationSystemTestCase
#   include ActionMailer::TestHelper
#   DatabaseCleaner.clean

#   test "User can get a magic link on first visit" do
#     DatabaseCleaner.cleaning do
#       user = create_authorized_user
#       visit logout_path
#       assert_current_path root_path

#       visit admin_users_path
#       assert_current_path root_path

#       ActionMailer::Base.deliveries.clear
#       fill_in "Email", with: user.email
#       click_on "Send My Magic Link"
#       email = ActionMailer::Base.deliveries.last
#       assert_equal email.to, [user.email]
#       assert_equal email.subject, "Emergent Commons - your magic link"
#       assert_match /#{get_unsubscribe_link(user)}/, email.header['List-Unsubscribe'].inspect
#       assert_match /#{get_magic_link(user)}/, email.body.inspect
#       ActionMailer::Base.deliveries.clear
#     end
#   end

#   test "Greeter can select a user from index view then change greeter and shadow in show view" do
#     DatabaseCleaner.cleaning do
#       admin = login
#       admin2 = create_user
#       admin3 = create_user
#       user = create_user

#       visit admin_users_path
#       assert_current_path admin_users_path
#       page.find("tr[data-id='#{user.id}'] td.user-name").click
#       sleep 1
#       assert_current_path admin_user_path(user.id)

#       assert_selector "h3", text: user.name
      
#       assert_selector "a.user-back[href='#{admin_users_url}']", text: "👈 Back"
#       assert_selector "a.user-profile-button[href='#{user.profile_url}']", text: "🙂 Profile"
#       assert_selector "a.user-chat-button[href='#{user.chat_url}']", text: "💬 Chat"

#       assert_selector "td.user-greeter a", text: "I will greet"
#       assert_selector "td.user-shadow a", text: "I will shadow"

#       ######################
#       # GREETER
#       click_link('I will greet')
#       sleep 1
#       user.reload
#       assert_equal admin.name, user.greeter.name
#       assert_selector "td.user-greeter a", text: admin.name
#       page.find("td.change-log").text.match /greeter changed: \(blank\) -> #{admin.name}/

#       # check when removing greeter
#       message = dismiss_prompt do
#         click_link(admin.name)
#       end
#       assert_equal "Remove yourself as greeter?", message
#       user.reload
#       assert_equal admin.id, user.greeter_id
#       assert_selector "td.user-greeter a", text: admin.name
      
#       accept_prompt do
#         click_link(admin.name)
#       end
#       sleep 1
#       user.reload
#       assert_nil user.greeter_id
#       assert_selector "td.user-greeter a", text: "I will greet"

#       # check when changing greeter
#       user.update(greeter_id: admin2.id)
#       visit admin_user_path(user.id)
#       assert_selector "td.user-greeter a", text: admin2.name

#       message = dismiss_prompt do
#         click_link(admin2.name)
#       end
#       assert_equal "You will greet instead?", message
#       user.reload
#       assert_equal admin2.id, user.greeter_id
#       assert_selector "td.user-greeter a", text: admin2.name
      
#       accept_prompt do
#         click_link(admin2.name)
#       end
#       sleep 1
#       user.reload
#       assert_equal admin.id, user.greeter_id
#       assert_selector "td.user-greeter a", text: admin.name

#       # clean up
#       user.update(greeter_id: nil)
#       visit admin_user_path(user.id)

#       ######################
#       # SHADOW
#       click_link('I will shadow')
#       sleep 1
#       user.reload
#       assert_equal admin.id, user.shadow_greeter.id
#       assert_selector "td.user-shadow a", text: admin.name
#       page.find("td.change-log").text.match /shadow_greeter changed: \(blank\) -> #{admin.name}/

#       # check when removing shadow greeter
#       message = dismiss_prompt do
#         click_link(admin.name)
#       end
#       assert_equal "Remove yourself as shadow greeter?", message
#       user.reload
#       assert_equal admin.id, user.shadow_greeter_id
#       assert_selector "td.user-shadow a", text: admin.name
      
#       accept_prompt do
#         click_link(admin.name)
#       end
#       sleep 1
#       user.reload
#       assert_nil user.shadow_greeter_id
#       assert_selector "td.user-shadow a", text: "I will shadow"

#       # check when changing greeter
#       user.update(shadow_greeter_id: admin3.id)
#       visit admin_user_path(user.id)
#       assert_selector "td.user-shadow a", text: admin3.name

#       message = dismiss_prompt do
#         click_link(admin3.name)
#       end
#       assert_equal "You will be the shadow greeter instead?\n(we prefer only one shadow greeter)", message
#       user.reload
#       assert_equal admin3.id, user.shadow_greeter_id
#       assert_selector "td.user-shadow a", text: admin3.name
      
#       accept_prompt do
#         click_link(admin3.name)
#       end
#       sleep 1
#       user.reload
#       assert_equal admin.id, user.shadow_greeter_id
#       assert_selector "td.user-shadow a", text: admin.name
#     end
#   end

#   test "Greeter can change user status and set meeting in show view" do
#     DatabaseCleaner.cleaning do
#       admin = login
#       existing_user = create_user
#       assert existing_user.when_timestamp

#       visit admin_user_path(existing_user.id)
#       assert_current_path admin_user_path(existing_user.id)

#       ####################
#       ## APPROVE BUTTON
#       assert !existing_user.joined
#       assert_equal "Pending", existing_user.status
#       assert_selector "a.btn.btn-primary.user-approve", text: "Approve"

#       existing_user.update(status: "Request Declined")
#       visit admin_user_path(existing_user.id)
#       assert_selector ".ui-selectmenu-text", text: existing_user.status
#       assert_no_selector "a.btn.btn-primary.user-approve", text: "Approve"

#       existing_user.update(status: "Scheduling Zoom")
#       existing_user.update(joined: true)
#       visit admin_user_path(existing_user.id)
#       assert_selector ".ui-selectmenu-text", text: existing_user.status
#       assert_no_selector "a.btn.btn-primary.user-approve", text: "Approve"

#       ####################
#       ## STATUS AND MEETING DATE
#       # cannot unless this admin is greeting
#       # assert_selector ".user-meeting-datetime", text: "2022-Dec-7 @ 3:30 AM"
#       assert_nil existing_user.greeter_id
#       find(".ui-selectmenu-text").click
#       message = dismiss_prompt do
#         find(".ui-menu-item-wrapper", text: "Zoom Scheduled", exact_text: true).click
#       end
#       assert_equal "You will greet this new member?", message
#       sleep 1
#       assert_nil existing_user.reload.greeter_id
      
#       visit admin_user_path(existing_user.id)

#       find(".ui-selectmenu-text").click
#       accept_prompt do
#         find(".ui-menu-item-wrapper", text: "Zoom Scheduled", exact_text: true).click
#       end
#       sleep 1
#       assert_equal admin.id, existing_user.reload.greeter_id

#       assert_selector ".ui-selectmenu-text", text: "Zoom Scheduled"
#       assert_no_selector "a.btn.btn-primary.user-approve", text: "Approve"
#       assert_equal "Zoom Scheduled", existing_user.reload.status
#       assert_selector ".user-meeting-datetime", text: ""
#       assert_nil existing_user.reload.when_timestamp

#       existing_user.update(when_timestamp: "2023 Jan 20 10:00")
#       find(".ui-selectmenu-text").click
#       find(".ui-menu-item-wrapper", text: "Zoom Done (completed)", exact_text: true).click
#       assert_selector ".ui-selectmenu-text", text: "Zoom Done (completed)"
#       assert_no_selector "a.btn.btn-primary.user-approve", text: "Approve"
#       assert_equal "Zoom Done (completed)", existing_user.reload.status
#       assert_nil existing_user.when_timestamp

#       assert_selector "td.change-log", text: existing_user.change_log.chomp
#       visit admin_user_path(existing_user.id)

#       ####################
#       ## MEETING
#       input = find("td.user-meeting-datetime input.datetime-picker")
#       input.click
#       message = accept_alert
#       assert_equal "Status must be Zoom Scheduled or Scheduling Zoom to set the Meeting date and time", message
#       find(".ui-selectmenu-text").click
#       find(".ui-menu-item-wrapper", text: "Scheduling Zoom", exact_text: true).click

#       input.click
#       message = dismiss_prompt
#       assert_equal "Set status to Zoom Scheduled?", message
#       sleep 1
#       assert_equal "Scheduling Zoom", existing_user.reload.status

#       input.click
#       accept_prompt
#       sleep 1
#       assert_equal "Zoom Scheduled", existing_user.reload.status

#       input.click
#       input.send_keys("2022-10-09 15:45")
#       input.send_keys [:enter]
#       message = dismiss_prompt
#       assert_equal "Are you sure you want to set the Zoom meeting in the past?", message
#       assert_selector "td.user-meeting-datetime input", text: ""
#       sleep 1
#       assert_nil existing_user.reload.when_timestamp

#       input.click
#       input.send_keys("2023-10-09 15:45")
#       input.send_keys [:escape]
#       sleep 2 # cannot be 1 for some reason...
#       assert_equal "2023-10-09T20:45:00Z", existing_user.reload.when_timestamp.picker_datetime
#       assert_selector "td.change-log", text: existing_user.change_log.chomp

#       # check date format in index view
#       visit admin_users_path
#       assert_selector ".user-meeting-datetime", text: "2023-Oct-9 @ 3:45 PM"
#       visit admin_user_path(existing_user.id)

#       # now check ability to delete
#       input.click
#       input.value.length.times { input.send_keys [:arrow_right] }
#       input.value.length.times { input.send_keys [:backspace] }
#       input.send_keys [:escape]
#       sleep 2
#       existing_user.reload
#       assert_nil existing_user.when_timestamp
#     end
#   end

#   test "Greeter can enter notes in show view" do
#     DatabaseCleaner.cleaning do
#       user = login
#       old_notes = user.notes

#       visit admin_user_path(user.id)
#       assert_current_path admin_user_path(user.id)

#       # find("td.user-notes.more i").click -- do not have to click if notes is <> ""
#       notes_css = "td.user-notes textarea"
#       assert_selector notes_css, text: old_notes

#       keys = " hello this is new notes"
#       find(notes_css).send_keys(keys)
#       sleep 2
#       user.reload
#       assert_equal old_notes + keys, user.notes
#       assert_selector "td.user-notes span", text: "saved"
#       page.find("td.change-log").text.match /notes changed: this are notes -> this are notes hello this is new notes/

#       keys = " hello this is more stuff"
#       find(notes_css).send_keys(keys)
#       assert_selector "td.user-notes span", text: ""

#       keys = ""
#       100.times {|i| keys += i.to_s}
#       find(notes_css).send_keys(keys)
#       sleep 2
#       page.find("td.change-log").text.match /notes changed: this are notes hello this is new notes hello this is more stuff -> (too long)/
#     end
#   end

#   test "Greeter can send email in show view" do
#     DatabaseCleaner.cleaning do
#       admin = login
#       existing_user = create_user
#       old_status = existing_user.status

#       visit admin_user_path(existing_user.id)
#       assert_current_path admin_user_path(existing_user.id)

#       assert_nil existing_user.greeter_id
#       message = dismiss_prompt do
#         click_link(existing_user.email)
#       end
#       assert_equal "You will greet this new member?", message
#       existing_user.reload
#       assert_nil existing_user.greeter_id
      
#       click_link(existing_user.email)
#       accept_prompt
#       sleep 1
#       assert_equal admin.id, existing_user.reload.greeter_id
#       message = dismiss_prompt
#       accept_prompt(with: "0") do
#         click_link(existing_user.email)
#       end
#       message = accept_alert
#       assert_equal "Choose an email template 1 through 5", message
#       assert_equal old_status, existing_user.status

#       accept_prompt(with: "6") do
#         click_link(existing_user.email)
#       end
#       message = accept_alert
#       assert_equal "Choose an email template 1 through 5", message
#       assert_equal old_status, existing_user.status
#     end
#   end

#   test "Greeter can sort members in index view" do
#     DatabaseCleaner.cleaning do
#       admin = login({
#         name: random_user_name,
#         request_timestamp: (Time.now-365.days).strftime("%Y-%m-%dT%H:%M:%SZ")
#       })
#       user1 = create_user({
#         name: "A B",
#         greeter_id: nil,
#         request_timestamp: (Time.now-3.days).strftime("%Y-%m-%dT%H:%M:%SZ")
#       })
#       user2 = create_user({
#         name: "A C",
#         greeter_id: admin.id,
#         request_timestamp: (Time.now-1.days).strftime("%Y-%m-%dT%H:%M:%SZ")
#       })
#       user3 = create_user({
#         name: "A D",
#         greeter_id: nil,
#         request_timestamp: (Time.now-2.days).strftime("%Y-%m-%dT%H:%M:%SZ")
#       })

#       visit admin_users_path
#       assert_current_path admin_users_path

#       assert_equal page.all(".user-name").collect(&:text), [user2.name, user3.name, user1.name]
#       page.find("th.name").click
#       assert_equal page.all(".user-name").collect(&:text), [user1.name, user2.name, user3.name]
#       page.find("th.name").click
#       assert_equal page.all(".user-name").collect(&:text), [user3.name, user2.name, user1.name]

#       assert_equal 3, page.all("tbody tr", visible: true).count
#       page.find("input#my-greetings").click
#       assert_equal 1, page.all("tbody tr", visible: true).count
#       page.find("input#my-greetings").click
#       assert_equal 3, page.all("tbody tr", visible: true).count
#     end
#   end
# end
