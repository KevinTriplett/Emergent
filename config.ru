# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server

# startup spiders in their own threads
class SpiderThread
  # Thread.new { NewUserSpider.parse! :wait_for_trigger }
  # Thread.new { ApproveUserSpider.parse! :wait_for_trigger }
end
