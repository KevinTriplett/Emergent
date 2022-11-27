require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Emergent
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.time_zone = "UTC"
    # config.eager_load_paths << Rails.root.join("extras")

    config.admin_name = ENV["ADMIN_NAME"]
    config.admin_password = ENV["ADMIN_PASSWORD"]
    config.mn_username = ENV["MN_USERNAME"]
    config.mn_password = ENV["MN_PASSWORD"]
  end
end
