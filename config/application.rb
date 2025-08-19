require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MediarumuDashboard
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.time_zone = "Jakarta"

    config.active_job.queue_adapter = :good_job

    config.locale = "id"
    config.i18n.default_locale = :id
    config.i18n.available_locales = [:en, :id]

    config.app_generators.scaffold_controller = :scaffold_controller

    # Remove the X-Frame-Options header
    config.action_dispatch.default_headers.delete('X-Frame-Options')

    # Add a Content-Security-Policy header
    config.action_dispatch.default_headers['Content-Security-Policy'] = "frame-ancestors 'self' chrome-extension://*"

    # config/application.rb or config/environments/production.rb
    config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWALL'
    }
  end
end
