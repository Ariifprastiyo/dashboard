require 'capybara/rspec'
require 'capybara-screenshot/rspec'


# Capybara.default_driver = :selenium_chrome
# Capybara.default_driver = :selenium

# headless driver
# Capybara.default_driver = :selenium_chrome_headless

if ENV['NO_HEADLESS']
  Capybara.default_driver = :selenium
else
  Capybara.register_driver :firefox_headless do |app|
    options = Selenium::WebDriver::Firefox::Options.new
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")

    Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
  end

  Capybara.default_driver = :firefox_headless
end

Capybara.default_max_wait_time = 5

Capybara.asset_host = 'http://localhost:3000'
