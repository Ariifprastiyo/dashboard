# frozen_string_literal: true

module ActiveTiktok::Models
  class Comment
    attr_reader :id, :text, :created_at, :username, :payload

    def initialize(**attributes)
      @id = attributes[:id]
      @text = attributes[:text]
      @created_at = attributes[:created_at]
      @username = attributes[:username]
      @payload = attributes[:payload]
    end
  end
end
