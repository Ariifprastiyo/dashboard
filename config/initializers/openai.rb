OpenAI.configure do |config|
  config.access_token = ENV["OPENAI_ACCESS_TOKEN"]
  config.organization_id = ENV["OPENAI_ORGANIZATION_ID"] # Optional
  config.log_errors = Rails.env == 'development' # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production.
end
