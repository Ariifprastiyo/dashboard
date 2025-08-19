# frozen_string_literal: true

module ActiveTiktok::Models
  class CommentsCollection
    attr_reader :comments, :media_id, :has_more, :cursor

    def initialize(comments:, media_id:, has_more:, cursor:)
      @comments = comments
      @media_id = media_id
      @has_more = has_more
      @cursor = cursor
    end
  end
end
