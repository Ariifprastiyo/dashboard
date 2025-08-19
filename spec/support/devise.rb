RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers

  config.before(:each) do
    Devise.mappings[:user] ||= Devise::Mapping.new(:user, {})
  end

  # Optional: Reset after each test
  config.after(:each) do
    Warden.test_reset!
  end
end
