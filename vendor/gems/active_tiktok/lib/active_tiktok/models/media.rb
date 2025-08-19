# frozen_string_literal: true

module ActiveTiktok::Models
  class Media
    attr_reader :id, :post_identifier, :caption, :post_created_at, :likes_count,
      :comments_count, :shares_count, :impressions, :reach, :engagement_rate, :cover, :payload, :username

    def initialize(**attributes)
      @id = attributes[:id]
      @post_identifier = attributes[:post_identifier]
      @caption = attributes[:caption]
      @post_created_at = attributes[:post_created_at]
      @likes_count = attributes[:likes_count]
      @comments_count = attributes[:comments_count]
      @shares_count = attributes[:shares_count]
      @impressions = attributes[:impressions]
      @reach = attributes[:reach]
      @engagement_rate = attributes[:engagement_rate]
      @cover = attributes[:cover]
      @payload = attributes[:payload]
      @username = attributes[:username]
    end
  end
end
