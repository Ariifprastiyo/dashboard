# frozen_string_literal: true

module ActiveTiktok::Models
  class MediasCollection
    attr_reader :medias, :user_id, :has_more, :cursor

    def initialize(medias:, user_id:, has_more:, cursor:)
      @medias = medias
      @user_id = user_id
      @has_more = has_more
      @cursor = cursor
    end
  end
end
