# frozen_string_literal: true

module SocialMediaAccountHelper
  def link_to_social_media_account(username, platform)
    case platform
    when 'instagram'
      link_to username, "https://www.instagram.com/#{username}", target: '_blank'
    when 'tiktok'
      link_to username, "https://www.tiktok.com/@#{username}", target: '_blank'
    end
  end
end
