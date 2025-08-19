# frozen_string_literal: true

# This module is used to provide convinient method regarding Publication information
# This can be used only for SocialMediaPublication class only
module SocialMediaPublication::PostInformation
  extend ActiveSupport::Concern

  included do
    raise 'Only for SocialMediaPublication class' unless self.name == 'SocialMediaPublication'

    after_initialize :get_post_id_from_url
  end

  def platform_full_url
    username = social_media_account.username
    if tiktok?
      return "https://www.tiktok.com/@#{username}/video/#{url}"
    end

    if instagram?
      return "https://www.instagram.com/p/#{url}"
    end

    nil
  end

  def public_url
    return '' if manual?
    if platform == 'instagram'
      "https://www.instagram.com/p/#{url}"
    elsif platform == 'tiktok'
      "https://www.tiktok.com/@#{social_media_account.username}/video/#{url}"
    end
  end

  def cover
    if platform == 'tiktok'
      payload['video']['zoomCover']['240']
    else
      self.thumbnail.variant(:thumb)
    end
  end

  def get_post_id_from_url
    return
    return unless url.present?

    return unless url.match URI::DEFAULT_PARSER.make_regexp

    uri = URI.parse(url)

    if uri.host.include?('instagram.com')
      # get post id from instagram path
      post_id = uri.path.gsub!(/(\/p\/|\/tv\/|\/reel\/|\/igtv\/)/, '').gsub!(/\/.*/, '')
    elsif uri.host.include?('tiktok.com')
      post_id = uri.path.split('/').last
    end

    self.url = post_id
  end

  # TODO: remove this method, change with date formatterß
  def created_at_in_formatted
    created_at.strftime('%d %b %Y %H:%M')
  end
end
