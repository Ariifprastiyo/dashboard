# frozen_string_literal: true

module ActiveTiktok::Models
  class User
    attr_reader :id, :username, :full_name, :profile_picture, :bio, :website, :media_count, :follows_count,
                :followed_by_count

    def initialize(**attributes)
      @id = attributes[:id]
      @username = attributes[:username]
      @full_name = attributes[:full_name]
      @profile_picture = attributes[:profile_picture]
      @bio = attributes[:bio]
      @website = attributes[:website]
      @media_count = attributes[:media_count]
      @follows_count = attributes[:follows_count]
      @followed_by_count = attributes[:followed_by_count]
    end
  end
end
