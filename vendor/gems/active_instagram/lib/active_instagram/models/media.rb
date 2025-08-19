# frozen_string_literal: true

module ActiveInstagram
  class Media
    attr_reader :id, :pk, :shortcode, :taken_at, :display_url, :thumbnail_url, :video_url, :product_type, :title, :video_duration, :video_view_count, :caption, :comments_count, :comments_disabled, :likes_count, :username

    def initialize(id:, pk:, shortcode:, taken_at:, display_url:, thumbnail_url:, video_url:, product_type:, title:, video_duration:, video_view_count:, caption:, comments_count:, comments_disabled:, likes_count:, username: nil)
      @id = id
      @pk = pk
      @shortcode = shortcode
      @taken_at = taken_at
      @display_url = display_url
      @thumbnail_url = thumbnail_url
      @video_url = video_url
      @product_type = product_type
      @title = title
      @video_duration = video_duration
      @video_view_count = video_view_count
      @caption = caption
      @comments_count = comments_count
      @comments_disabled = comments_disabled
      @likes_count = likes_count
      @username = username
    end
  end
end
