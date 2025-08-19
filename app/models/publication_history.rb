# frozen_string_literal: true

class PublicationHistory < ApplicationRecord
  belongs_to :social_media_publication

  # this is cached info to simplify report queries
  belongs_to :campaign, optional: true
  belongs_to :social_media_account, optional: true

  include Platformable

  enum :social_media_account_size, { nano: 0, micro: 1, macro: 2, mega: 3 }
  # end cahced info

  ##
  # Get the latest id of publication history for a given social media publication,
  # in a given time range. This is used to get the latest snapshot of publication metrics data.
  scope :newest_publication_histories, -> (start_date, end_date) {
    where(id: self.where(created_at: start_date..end_date)
                  .select('MAX(id)')
                  .group(:social_media_publication_id))
  }

  after_save :recalculate_campaign_metrics

  def self.ransackable_attributes(auth_object = nil)
    ["campaign_id", "comments_count", "created_at", "engagement_rate", "id", "id_value", "impressions", "likes_count", "platform", "reach", "related_media_comments_count", "saves_count", "share_count", "social_media_account_id", "social_media_account_size", "social_media_publication_id", "updated_at"]
  end

  def total_engagement
    likes_count + comments_count + share_count + saves_count
  end

  def publication_additional_info
    social_media_publication.additional_info
  end

  def recalculate_campaign_metrics
    return if social_media_publication.campaign.nil?
    social_media_publication.campaign.recalculate_metrics
  end

  def self.create_from_social_media_publication(publication)
    return if publication.campaign.nil?
    publication.publication_histories.create(
      likes_count: publication.likes_count,
      comments_count: publication.comments_count,
      impressions: publication.impressions,
      reach: publication.reach,
      engagement_rate: publication.engagement_rate,
      share_count: publication.share_count,
      campaign_id: publication.campaign_id,
      platform: publication.platform,
      social_media_account_size: publication.social_media_account.size,
      social_media_account_id: publication.social_media_account_id,
      related_media_comments_count: publication.related_media_comments_count
    )
  end
end
