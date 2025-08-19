# frozen_string_literal: true

module ActiveInstagram
  class Comment
    attr_reader :pk, :text, :created_at, :user

    def initialize(pk:, text:, created_at:, user:)
      @pk = pk
      @text = text
      @created_at = created_at
      @user = user
    end
  end
end
