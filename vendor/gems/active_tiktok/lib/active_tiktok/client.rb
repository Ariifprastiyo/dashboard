# frozen_string_literal: true

module ActiveTiktok
  # The ActiveTiktok module provides a client for interacting with the Tiktok API.
  class Client
    attr_reader :drivers

    def initialize(config)
      @drivers = []

      config.providers.each do |provider|
        @drivers.push case provider[:provider]
                      when :tikapi
                        ::ActiveTiktok::Drivers::Tikapi.new(api_key: provider[:api_key], account_key: provider[:account_key])
                      when :tokapi_mobile
                        ::ActiveTiktok::Drivers::TokapiMobile.new(api_key: provider[:api_key])
        end
      end
    end

    def media_by_id(code)
      with_failover do |driver|
        driver.media_by_id(code)
      end
    end

    def comments_by_media_id(code, cursor = 0)
      with_failover do |driver|
        driver.comments_by_media_id(code, cursor)
      end
    end

    def user_by_username(username)
      with_failover do |driver|
        driver.user_by_username(username)
      end
    end

    def medias_by_user_id(user_id)
      with_failover do |driver|
        driver.medias_by_user_id(user_id)
      end
    end

    private
      # Executes the given block of code with failover support.
      #
      # This method iterates over the drivers and attempts to execute the block of code
      # with each driver. If an exception occurs, it moves on to the next driver until
      # either the block of code is successfully executed or all drivers have been tried.
      #
      # If all drivers fail to execute the block of code, the last raised exception is
      # re-raised.
      #
      # @yield [driver] The block of code to be executed with each driver.
      # @yieldparam driver [Object] The current driver being used.
      # @raise [StandardError] If all drivers fail to execute the block of code.
      def with_failover
        last_error = nil

        @drivers.each do |driver|
          puts "Trying with #{driver.class.name}"
          return yield(driver)
        rescue StandardError => e
          last_error = e
          next
        end

        raise last_error if last_error
      end
  end
end
