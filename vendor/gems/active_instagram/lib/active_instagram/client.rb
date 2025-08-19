# frozen_string_literal: true

module ActiveInstagram
  # The ActiveInstagram module provides a client for interacting with the Instagram API.
  class Client
    attr_reader :driver, :api_key

    def initialize(driver: "hikerapi", api_key: "xxxx")
      @driver = case driver
                when :hikerapi
                  ::ActiveInstagram::Drivers::Hikerapi.new(api_key: api_key)
      end
    end

    def profile_by_username(username)
      @driver.profile_by_username(username)
    end

    def media_by_code(code)
      @driver.media_by_code(code)
    end

    def medias_by_user_id(user_id)
      @driver.medias_by_user_id(user_id)
    end

    def comments_by_media_id(media_id, page_id = nil)
      @driver.comments_by_media_id(media_id, page_id)
    end
  end
end
