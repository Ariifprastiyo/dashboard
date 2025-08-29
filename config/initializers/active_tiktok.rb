ActiveTiktok.configure do |config|
  config.add_provider provider: :tokapi_mobile, api_key: ENV["TOKAPI_API_KEY"]
  config.add_provider provider: :tikapi, api_key: ENV["TIKAPI_API_KEY"], account_key: ENV["TIKAPI_ACCOUNT_KEY"]
end
