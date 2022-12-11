# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server

puts "$CHROME_USER_DATA_DIR = #{ENV["CHROME_USER_DATA_DIR"]}"
