require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_group "Libraries", "lib/"
end

require "active_tiktok"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


#  VCR
require 'vcr'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr_cassettes"
  c.ignore_localhost = true
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  c.ignore_hosts(
    'codeclimate.com',
    'localhost',
    '127.0.0.1',
    "github.com",
    "chromedriver.storage.googleapis.com",
    "api.github.com",
    "selenium-release.storage.googleapis.com",
    "developer.microsoft.com",
    'objects.githubusercontent.com'
  )
end
