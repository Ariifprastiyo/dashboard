# frozen_string_literal: true

module ActiveInstagram
  class User
    attr_reader :id, :username, :full_name, :profile_picture, :bio, :website, :media_count, :follows_count, :followed_by_count

    def initialize(id:, username:, full_name:, profile_picture:, bio:, website:, media_count:, follows_count:, followed_by_count:)
      @id = id
      @username = username
      @full_name = full_name
      @profile_picture = profile_picture
      @bio = bio
      @website = website
      @media_count = media_count
      @follows_count = follows_count
      @followed_by_count = followed_by_count
    end
  end
end
