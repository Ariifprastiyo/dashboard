# frozen_string_literal: true

class SocialMediaPublication < ApplicationRecord
  include Platformable
  include PostAndCommentFetcher
  include MetricCalculator
  include PostInformation

  # Relationship
  belongs_to :campaign, optional: true  # Keep for backward compatibility
  has_one :brand, through: :campaign
  belongs_to :social_media_account, optional: true
  belongs_to :scope_of_work, optional: true
  belongs_to :scope_of_work_item, optional: true
  has_many :publication_histories, dependent: :destroy
  has_many :media_comments, dependent: :destroy
  has_many :publication_associations
  has_many :campaigns, through: :publication_associations,
           source: :associable, source_type: 'Campaign'

  # ActiveStorage attachment
  has_one_attached :proof, dependent: :destroy do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [100, 100]
    attachable.variant :medium, resize_to_limit: [300, 300]
    attachable.variant :large, resize_to_limit: [600, 600]
  end

  # thumbnail attachment
  has_one_attached :thumbnail, dependent: :destroy do |attachable|
    attachable.variant :default, resize_to_limit: [100, 100]
    attachable.variant :thumb, resize_to_limit: [50, 50]
  end

  # Validations
  validates :url, presence: true
  validates :platform, presence: true
  validates :url, uniqueness: { scope: :platform }, format: { without: /\s/ }

  # Callbacks
  after_commit :update_scope_of_work_item_posted_at, on: :create

  # Delegations
  delegate :keyword, :hashtag, to: :campaign, allow_nil: true
  delegate :tiktok, to: :brand, prefix: true, allow_nil: true
  delegate :username, :size, to: :social_media_account, prefix: true

  # TODO: complete kinds and check what is available in the API
  # enum kind: { video: 0, post: 1, story: 2, tweet: 3, blog: 4, image: 5, thread: 6, podcast: 7, track: 8, other: 9, reels: 10, stream: 11, feed: 12, igtv: 13, carousel: 14 }

  # Scopes
  scope :by_platform, -> (platform) { joins(:social_media_account).where(social_media_accounts: { platform: platform }) }
  scope :need_sync_daily_update, -> do
    joins(:campaign)
      .where(manual: false)
      .where(campaigns: { status: :active })
      .where(deleted_by_third_party: false)
      .where('campaigns.start_at <= ?', Time.current)
      .where('campaigns.end_at >= ?', Time.current)
  end
  scope :last_sync_older_than_24_hours, -> { where("last_sync_at < ?", 24.hours.ago) }

  def self.ransackable_attributes(auth_object = nil)
    ["additional_info", "campaign_id", "caption", "comments_count", "created_at",
     "deleted_by_third_party", "engagement_rate", "id", "id_value", "impressions",
     "kind", "last_error_during_sync", "last_sync_at", "likes_count", "manual",
     "media_comments_count", "payload", "platform", "post_created_at", "post_identifier",
     "reach", "related_media_comments_count", "saves_count", "scope_of_work_id",
     "scope_of_work_item_id", "share_count", "social_media_account_id", "updated_at",
     "url", "publishable_type", "publishable_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["brand", "campaign", "media_comments", "proof_attachment", "proof_blob",
     "publication_histories", "scope_of_work", "scope_of_work_item",
     "social_media_account", "thumbnail_attachment", "thumbnail_blob", "publishable"]
  end

  # This methods will re-calculate the last publication history metrics
  # Useful when theres a bug or glitch in the system and we need to re-calculate the metrics
  # PublicationHistory is one of the most important data in the reporting system
  def recalculate_the_last_publication_history_metrics
    last_publication_history = publication_histories.last
    last_publication_history.update(
      likes_count: likes_count,
      comments_count: comments_count,
      impressions: impressions,
      reach: reach,
      engagement_rate: engagement_rate,
      share_count: share_count,
      related_media_comments_count: related_media_comments_count
    )
  end

  def update_scope_of_work_item_posted_at
    if self.post_created_at.present? && self.scope_of_work_item.present?
      self.scope_of_work_item.update(posted_at: self.post_created_at)
    end
  end

  # TODO: Add tests
  def crb
    return 0 if media_comments_count.zero?
    (related_media_comments_count / media_comments_count.to_f) * 100
  end
end
