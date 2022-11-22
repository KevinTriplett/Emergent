require 'test_helper'

class MemberTest < MiniTest::Spec
  include ActionMailer::TestHelper
  DatabaseCleaner.clean
end