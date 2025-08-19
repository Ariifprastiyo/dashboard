# frozen_string_literal: true

require 'httparty'

require_relative "active_instagram/version"
require_relative "active_instagram/configuration"
require_relative "active_instagram/client"
require_relative "active_instagram/drivers/hikerapi"
require_relative "active_instagram/models/user"
require_relative "active_instagram/models/media"
require_relative "active_instagram/models/comment"
require_relative "active_instagram/models/profile"

module ActiveInstagram
  class Error < StandardError; end
  module Drivers
    class ProfileNotFoundError < StandardError; end
    class ProfileIsPrivateError < StandardError; end
    class MediaNotFoundError < StandardError; end
    class ServerError < StandardError; end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.profile_by_username(username)
    client.profile_by_username(username)
  end

  def self.media_by_code(code)
    client.media_by_code(code)
  end

  def self.medias_by_user_id(user_id)
    client.medias_by_user_id(user_id)
  end

  def self.comments_by_media_id(media_id, page_id = nil)
    client.comments_by_media_id(media_id, page_id)
  end

  private
    def self.client
      @client ||= Client.new(driver: configuration.driver, api_key: configuration.api_key)
    end
end
