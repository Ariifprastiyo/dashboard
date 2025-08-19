# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.3"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", ">= 8.0.1"

gem "solid_cache"
gem "solid_cable"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.5.4"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

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
gem "image_processing", "~> 1.12.2"

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem "rack-mini-profiler"

  gem "rack-cors"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "guard-bundler"
  gem "guard-rspec"
  gem "terminal-notifier-guard"
  gem "solargraph"
  gem 'bullet'
  gem 'rails-erd'
  gem 'rufo'
  gem "dockerfile-rails", ">= 1.6"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 6.1.2"
  gem 'dotenv-rails'
  gem "byebug", "~> 11.1"
  gem 'pundit-matchers', '~> 3.1'
  gem "hotwire-spark"


  # code quality
  gem 'brakeman'
  gem 'rubocop', '~> 1.53.0', require: false
  gem 'rubocop-rails'
  gem 'rubocop-performance'
  gem 'rubocop-packaging'
  gem 'rubocop-rake', '~> 0.6.0'
  gem 'rubocop-rspec', '~> 2.11.0'
  gem 'rubycritic', require: false
  gem 'mock_redis'
  gem 'marginalia'
end

group :test do
  gem "capybara"
  gem 'capybara-screenshot'
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "shoulda-matchers"
  gem "vcr"
  gem "webmock", require: "webmock/rspec"
  gem "timecop"
  gem 'simplecov', require: false
  gem 'rspec-retry'
end

# Auth
gem "devise", "~> 4.9.4"
gem "devise-bootstrap5", "~> 0.1.3"
gem "devise-i18n", "~> 1.10"
gem "rolify", "~> 6.0"
gem "pundit", "~> 2.4.0"

# ActiveRecord extensions
gem "kaminari", "~> 1.2"
gem "active_storage_validations", "~> 1.3.4"
gem "ransack", "~> 4.2.1"
gem "groupdate", "~> 6.1"
gem 'acts-as-taggable-on', '~> 12.0.0'
## Advance version of counter cache
gem 'counter_culture', '~> 3.2'
gem 'discard', '~> 1.2'

# UI
gem "gravtastic", "~> 3.2"
gem "bootstrap_form", "~> 5.4.0"
gem "bootstrap5-kaminari-views", "~> 0.0.1"
gem "active_link_to", "~> 1.0"
gem "chartkick", "~> 4.2"
gem "rails-i18n", "~> 8.0"
gem "simple_calendar", "~> 2.4"

# Reporting
gem "prawn", "~> 2.4"
gem "prawn-table", "~> 0.2.2"
gem 'caxlsx', '~> 4.0'
# gem "matrix", "~> 0.4.2"
# read access for all common spreadsheet types
gem "roo", "~> 2.9.0"

# Admin
gem "activeadmin", ">= 3.2.0"

# Background jobs & scheduling
gem "good_job", "~> 3.23"

# System and App Monitoring
gem "sentry-ruby"
gem "sentry-rails", "~> 5.14"
gem 'newrelic_rpm'
gem "lograge", "~> 0.14.0"

# utils
gem "httpparty", "~> 0.2.0"
gem "faraday", "~> 2.7"
gem "ostruct", "~> 0.5.5"
gem 'turnout'
gem "aws-sdk-s3", "~> 1.167", require: false

gem "active_instagram", path: "./vendor/gems/active_instagram"
gem "active_tiktok", path: "./vendor/gems/active_tiktok"

gem "rmagick"
gem "magic_cloud"

# Analytics
gem "ahoy_matey", "~> 5.2"
gem "blazer", "~> 2.6"

# Feature flags
gem "flipper", "~> 1.3"
gem "flipper-active_record", "~> 1.3"
gem "flipper-ui", "~> 1.3"

# AI and ML
gem "kmeans-clusterer", "~> 0.11.4"
gem "ruby-openai", "~> 7.0"
gem "pgvector", "~> 0.3.2"
gem "neighbor"

gem 'redcarpet'

gem "rails_local_analytics", "~> 0.2.4"
