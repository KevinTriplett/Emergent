source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4"

gem "trailblazer-macro-contract"
gem "trailblazer"
gem "trailblazer-rails"
gem "trailblazer-cells"
gem "dry-validation"
gem "cells-hamlit"
gem "cells-rails"
gem "reform"
gem "rolify"
gem "ruby-openai"
# gem "anthropic"

# web scraping
gem "kimurai", path: "vendor/bundle/kimuraframework"
gem "whenever", require: false
gem "simple_form"
gem "haml"
gem "redcarpet"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
# gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :production do
  gem "concurrent-ruby", "1.3.4" # 1.3.5 hangs with "uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger"
end

group :development, :production do
  gem "pg", "~> 1.1"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # deploy...
  gem 'capistrano', "~> 3.19.0"
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-passenger'
  gem 'capistrano-rbenv'
  gem 'capistrano-ssh-doctor'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use sqlite3 as the database for Active Record
  gem "sqlite3", "~> 1.4"
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "minitest-line"
  gem "database_cleaner-active_record"
  gem "rails-controller-testing"
  gem "chroma"
end
