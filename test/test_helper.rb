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
  end while Member.find_by_email(last_random_email)
  @_last_random_email
end

def last_random_email
  @_last_random_email
end

def random_member_name
  @_last_random_member_name = "#{ NAMES.sample } #{ SURNAMES.sample }"
end

def last_random_member_name
  @_last_random_member_name
end

def create_member(params = {})
  Member::Operation::Create.call(
    params: {
      member: {
        name: params[:name] || random_member_name,
        email: params[:email] || random_email,
        profile_url: params[:profile_url],
        chat_url: params[:chat_url],
        request_timestamp: params[:request_timestamp],
        join_timestamp: params[:join_timestamp] || "12/08/2022",
        status: params[:status] || "existing",
        location: params[:location] || "Austin, Texas",
        questions_responses: params[:questions_responses],
        notes: params[:notes],
        referral: params[:referral]
      }
    }
  )[:model]
end
