# frozen_string_literal: true

module ActiveTiktok
  class Configuration
    attr_accessor :providers

    def initialize(providers = [])
      @providers = providers
    end

    def add_provider(provider:, api_key:, account_key: nil)
      @providers << { provider: provider, api_key: api_key, account_key: account_key }
    end
  end
end
