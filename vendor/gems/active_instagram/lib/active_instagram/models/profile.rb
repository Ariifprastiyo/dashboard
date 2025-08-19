# frozen_string_literal: true

module ActiveInstagram
  class Profile
    attr_reader :user, :medias

    def initialize(user:, medias: [])
      @user = user
      @medias = medias
    end
  end
end
