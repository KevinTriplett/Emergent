ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require 'spec/spec_helper'

############################
#
class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: 0)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
end

############################
# database cleaner
require 'database_cleaner/active_record'
DatabaseCleaner.strategy = :transaction
DatabaseCleaner.clean_with :truncation

############################
# app-specific test helpers

NAMES = %w(john jane eric lee harvey sam kevin hank)
SURNAMES = %w(smith jones doe windsor johnson klaxine)
PROVIDERS = %w(gmail domain example sample yahoo gargole)
TLDS = %w(com it org club pl ru uk aus)
def random_email
  begin
    @_last_random_email = "#{ NAMES.sample }.#{ SURNAMES.sample }@#{ PROVIDERS.sample }.#{ TLDS.sample }"
  end while User.find_by_email(last_random_email)
  @_last_random_email
end

def last_random_email
  @_last_random_email
end

def random_user_name
  @_last_random_user_name = "#{ NAMES.sample } #{ SURNAMES.sample }"
end

def last_random_user_name
  @_last_random_user_name
end

def mock_qna
  "1q\\2a -:- 2q\\2a -:- 3q\\3a -:- 4q\\4a -:- 5q\\5a"
end

def create_authorized_user(params = {})
  user = create_user(params)
  user.update(session_token: "H5_LTSXsGWDKkP7V_-aHvA")
  user
end

def set_authorization_cookie
  cookies["session_token"] = "gir7nKs/L502O3MpBzkF7RwmUbjZpCw3AU/wEYILeSj8mR75jiqctml0U77UwkSII0v8LjsjlZMI2Vxx8VOtIQhAtmb1DxMwAThapI1GE9e2xgHInVo2sOXu9i6mh5Jnpw==--P972pwxiT1N1w2jV--Jr7SHvdlHtGCYVeUTJRtTw=="
end

def create_user_with_result(params = {})
  User::Operation::Create.call(
    params: {
      user: {
        name: params[:name] || random_user_name,
        email: params[:email] || random_email,
        profile_url: params[:profile_url] || "https://example.com/profile/12345",
        chat_url: params[:chat_url] || "https://example.com/chat/12345",
        when_timestamp: params[:when_timestamp] || "07/12/2022",
        request_timestamp: params[:request_timestamp] || "08/12/2022",
        join_timestamp: params[:join_timestamp] || "09/12/2022",
        status: params[:status] || "Joined!",
        location: params[:location] || "Austin, Texas",
        questions_responses: params[:questions_responses] || mock_qna,
        notes: params[:notes] || "this are notes",
        referral: params[:referral] || "referral name",
        greeter_id: params[:greeter_id],
        shadow_greeter_id: params[:shadow_greeter_id],
        session_token: params[:session_token]
      }
    }
  )
end

def login(params = {})
  user = create_authorized_user(params)
  visit login_url(token: user.token)
  user
end

def create_user(params = {})
  create_user_with_result(params)[:model]
end

def get_magic_link(user)
  "https://test.emergentcommons.app/login/#{user.token}"
end

def get_unsubscribe_link(user)
  "https://test.emergentcommons.app/unsubscribe/#{user.token}"
end
