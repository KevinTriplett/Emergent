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
    config.from_email_adr = "noreply@emergentcommons.app"

    config.mn_greeter_username = ENV["MN_GREETER_USERNAME"]
    config.mn_greeter_password = ENV["MN_GREETER_PASSWORD"]
    config.mn_moderation_username = ENV["MN_MODERATION_USERNAME"]
    config.mn_moderation_password = ENV["MN_MODERATION_PASSWORD"]
    config.mn_surveyor_username = config.mn_greeter_username
    config.mn_surveyor_password = config.mn_greeter_password
    # TODO: restore when/if surveyor account is created
    # config.mn_surveyor_username = ENV["MN_SURVEYOR_USERNAME"]
    # config.mn_surveyor_password = ENV["MN_SURVEYOR_PASSWORD"]
    
    config.openai_api_key = ENV["OPENAI_API_KEY"]
  end
end
