# frozen_string_literal: true

# This module is used to fetch and populate post data from social media platform
# This can be used only for SocialMediaPublication class only
module SocialMediaPublication::PostAndCommentFetcher
  extend ActiveSupport::Concern

  included do
    raise 'Only for SocialMediaPublication class' unless self.name == 'SocialMediaPublication'

    after_create :fetch_and_populate_post_data
    validate :check_if_post_exists, on: :create
    after_commit :create_or_sync_media_comments, on: :create
  end

  # Try to fetch and populate post data from social media platform
  def fetch_and_populate_post_data(options = {})
    return if self.manual?
    case platform
    when 'instagram'
      fetch_and_populate_instagram_post_data(options)
    when 'tiktok'
      fetch_and_populate_tiktok_post_data(options)
    end
  end

  def fetch_and_populate_instagram_post_data(options = {})
    begin
      media = ActiveInstagram.media_by_code(self.url)
      rescue ActiveInstagram::Drivers::MediaNotFoundError => e
        message = "Instagram Profile not Found for #{self.url} - #{e.message}"
        Sentry.capture_message(message)
        self.update(last_error_during_sync: message, deleted_by_third_party: true)
        return false
      rescue ActiveInstagram::Drivers::ServerError => e
        message = "Instagram Server Error for #{self.url} - #{e.message}"
        Sentry.capture_message(message)
        self.update(last_error_during_sync: message)
        raise ActiveInstagram::Drivers::ServerError if options[:raise_exception]
        return false
    end

    # lets not use this approach for while, lets assume that the social media account is the one assigned from controller
    # platform_user_identifier = result['user']['pk']
    # social_media_account = SocialMediaAccount.find_by(platform_user_identifier: platform_user_identifier)

    impressions = media.video_view_count

    reach = impressions * 0.8
    engagement_rate = ((media.likes_count + media.comments_count) / impressions.to_f) * 100

    thumbnail_url = media.thumbnail_url
    # attach thumbnail based on thumbnail url
    self.thumbnail.attach(io: URI.open(thumbnail_url), filename: "#{self.url}.jpg") if thumbnail_url.present?

    # Parse from UTC
    post_created_at = Time.parse("#{media.taken_at} UTC")
    self.update(
      post_identifier: media.pk,
      post_created_at: post_created_at,
      caption: media.caption,
      likes_count: media.likes_count,
      comments_count: media.comments_count,
      impressions: impressions,
      reach: reach,
      engagement_rate: engagement_rate,
      share_count: 0,
      last_sync_at: Time.now,
      last_error_during_sync: nil,
      social_media_account_id: self.social_media_account.id,
      payload: JSON.parse(media.to_json),
      kind: media.product_type
    )
  end

  def fetch_and_populate_tiktok_post_data(options = {})
    begin
      result = ActiveTiktok.media_by_id(self.url)
    rescue ActiveTiktok::Drivers::MediaNotFoundError => e
      message = "Tiktok Post not Found for #{self.url} - #{e.message}"
      self.update(last_error_during_sync: message, deleted_by_third_party: true)
      # Sentry.capture_message(message)
      Rails.logger.error(message)
      return false
    rescue ActiveTiktok::Drivers::InvalidIdError => e
      message = "InvalidID for #{self.url} - #{e.message}"
      self.update(last_error_during_sync: message, deleted_by_third_party: true)
      Sentry.capture_message(message)
      Rails.logger.error(message)
      return false
    rescue ActiveTiktok::Error => e
      message = "Tiktok Server Error for #{self.url} - #{e.message}"
      self.update(last_error_during_sync: message)
      Sentry.capture_message(message)
      Rails.logger.error(message)
      return false
    end

    likes_count = result.likes_count
    comments_count = result.comments_count
    shares_count = result.shares_count
    impressions = result.impressions

    engagement_rate = result.engagement_rate

    # attach thumbnail based on thumbnail url
    thumbnail_url = result.cover
    self.thumbnail.attach(io: URI.parse(thumbnail_url).open, filename: "#{self.url}.jpg") if thumbnail_url.present?

    self.update(
      post_identifier: result.post_identifier,
      post_created_at: Time.at(result.post_created_at),
      caption: result.caption,
      likes_count: likes_count,
      comments_count: comments_count,
      impressions: impressions,
      reach: impressions,
      engagement_rate: engagement_rate,
      share_count: shares_count,
      last_sync_at: Time.now,
      last_error_during_sync: nil,
      social_media_account_id: social_media_account.id,
      payload: result,
      kind: :video,
    )
  end

  def create_media_comment_for_tiktok(comment)
    return if comment.text.blank?

    media_comment = media_comments.find_by(
      platform_id: comment.id,
      platform: :tiktok
    )
    return false if media_comment.present?

    media_comments.create!(
      platform_id: comment.id,
      content: comment.text,
      payload: comment.payload,
      platform: :tiktok,
      comment_at: Time.at(comment.created_at)
    )
  end

  def create_media_comment_for_ig(comment)
    return if comment.text.blank?

    # use either pk or id as platform_id
    platform_identifier = comment.pk || comment.id

    # use either created_at or created_at_utc as comment_at
    commented_at = if comment.created_at.present?
      Time.at(comment.created_at).to_datetime
    end

    media_comment = media_comments.find_by(
      platform_id: platform_identifier,
      platform: :instagram
    )
    return false if media_comment.present?

    media_comments.create!(
      platform_id: platform_identifier,
      content: comment.text,
      payload: comment.to_json,
      platform: :instagram,
      comment_at: commented_at
    )
  end

  def create_or_sync_media_comments
    if tiktok?
      return CreateMediaCommentsAndPublicationHistoryForTiktokJob.perform_later(self.id)
    end

    if instagram?
      return CreateMediaCommentsAndPublicationHistoryForInstagramJob.perform_later(self.id)
    end

    false
  end

  def sync_daily_update(options = {})
    # return false if last_sync_at is today
    return false if (last_sync_at&.to_date == Time.zone.today) && !options[:force]
    return false if manual?

    if fetch_and_populate_post_data(options)
      # sync comments only if fetch_and_populate_post_data is successful
      create_or_sync_media_comments
    end
  end

  private
    def check_if_post_exists
      return if manual?

      case platform
      when 'instagram'

      when 'tiktok'
        begin
          ActiveTiktok.media_by_id(self.url)
        rescue ActiveTiktok::Error
          errors.add(:url, "Tiktok Post not Found for #{self.url}")
        end
      end
    end
end
