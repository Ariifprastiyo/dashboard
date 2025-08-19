# frozen_string_literal: true

module ActiveInstagram
  class Configuration
    attr_accessor :api_key, :driver

    def initialize(api_key: nil, driver: nil)
      @api_key = api_key
      @driver = driver
    end
  end
end
