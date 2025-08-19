ActiveInstagram.configure do |config|
  config.api_key = ENV["HIKER_API_KEY"] || ENV["DATALAMA_ACCESS_KEY"]
  config.driver = :hikerapi
end
