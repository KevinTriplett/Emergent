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

def create_user_with_result(params = {})
  User::Operation::Create.call(
    params: {
      user: {
        name: params[:name] || random_user_name,
        email: params[:email] || random_email,
        profile_url: params[:profile_url] || "https://example.com",
        chat_url: params[:chat_url],
        welcome_timestamp: params[:welcome_timestamp] || "07/12/2022",
        request_timestamp: params[:request_timestamp] || "08/12/2022",
        join_timestamp: params[:join_timestamp] || "09/12/2022",
        status: params[:status] || "Joined!",
        location: params[:location] || "Austin, Texas",
        questions_responses: params[:questions_responses] || "1q\\2a -:- 2q\\2a -:- 3q\\3a -:- 4q\\4a -:- 5q\\5a",
        notes: params[:notes] || "this are notes",
        referral: params[:referral] || "referral name",
        greeter: params[:greeter]
      }
    }
  )
end

def create_user(params = {})
  create_user_with_result(params)[:model]
end