require 'vcr'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join('spec', 'cassettes')
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

RSpec.configure do |config|
  # Add VCR to all tests
  config.around(:each) do |example|
    options = example.metadata[:vcr] || {}
    options[:allow_playback_repeats] = true
    if options[:record] == :skip
      WebMock.allow_net_connect!
      VCR.turned_off(ignore_cassettes: true, &example)
      WebMock.disable_net_connect!(allow_localhost: false)
    else
      name = example.metadata[:full_description].split(/\s+/, 2).join('/').underscore.tr('.', '/').gsub(/[^\w\/]+/, '_').gsub(/\/$/, '')
      VCR.use_cassette(name, options, &example)
    end
  end
end
