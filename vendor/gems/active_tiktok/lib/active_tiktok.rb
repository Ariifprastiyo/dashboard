# frozen_string_literal: true

require 'dotenv/load' unless ENV['RAILS_ENV'] == 'production'

require_relative "active_tiktok/version"
require_relative "active_tiktok/configuration"
require_relative "active_tiktok/client"
require_relative "active_tiktok/drivers/base"
require_relative "active_tiktok/drivers/tikapi"
require_relative "active_tiktok/drivers/tokapi_mobile"
require_relative "active_tiktok/models/user"
require_relative "active_tiktok/models/media"
require_relative "active_tiktok/models/medias_collection"
require_relative "active_tiktok/models/comments_collection"
require_relative "active_tiktok/models/comment"

module ActiveTiktok
  class Error < StandardError; end
  module Drivers
    class UnauthorizedError < Error; end
    class MediaNotFoundError < Error; end
    class InvalidIdError < Error; end
    class MediaGeneralError < Error; end
    class UserNotFoundError < Error; end
    class RateLimitError < Error; end
    class ServerError < Error; end
    class LimitError < Error; end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration = Configuration.new
    yield(configuration)
  end

  def self.media_by_id(id)
    client.media_by_id(id)
  end

  def self.comments_by_media_id(id, cursor = 0)
    client.comments_by_media_id(id, cursor)
  end

  def self.user_by_username(username)
    client.user_by_username(username)
  end

  def self.medias_by_user_id(user_id)
    client.medias_by_user_id(user_id)
  end

  private
    def self.client
      @client = Client.new(configuration)
    end
end
