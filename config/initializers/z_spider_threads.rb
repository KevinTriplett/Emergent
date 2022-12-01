require 'new_user_spider'
require 'approve_user_spider'

class SpiderThread
  unless Rails.const_defined?( "Console" )
    Thread.new { NewUserSpider.parse! :wait_for_trigger }
    Thread.new { ApproveUserSpider.parse! :wait_for_trigger }
  end
end