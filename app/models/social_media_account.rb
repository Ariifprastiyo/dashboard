# frozen_string_literal: true

require 'open-uri'
class SocialMediaAccount < ApplicationRecord
  include Discard::Model
  include Platformable

  # Relationship
  belongs_to :influencer
  accepts_nested_attributes_for :influencer

  has_and_belongs_to_many :categories
  has_and_belongs_to_many :managements, join_table: "managements_accounts"

  has_many :scope_of_works
  has_many :media_plans, through: :scope_of_works

  has_one_attached :profile_picture, dependent: :destroy do |attachable|
    attachable.variant :thumb, resize_to_limit: [50, 50]
    attachable.variant :normal, resize_to_limit: [100, 100]
  end

  has_many :payment_requests, as: :beneficiary

  has_many :social_media_publications

  # Validations
  validates :platform, :username, presence: true
  validates :username, uniqueness: { scope: :platform, conditions: -> { undiscarded } }
  validates :username, format: { without: /\s/ }
  validates :story_price, :story_session_price,
            :feed_photo_price, :feed_video_price,
            :reel_price, :live_price, :owning_asset_price,
            :tap_link_price, :link_in_bio_price, :live_attendance_price,
            :host_price, :comment_price, :photoshoot_price,
            :other_price, numericality: true

  # Scopes
  scope :by_platform, -> (platform) { where(platform: platform) }
  scope :instagram, -> { where(platform: 'instagram') }
  scope :tiktok, -> { where(platform: 'tiktok') }


  # Enums
  enum :kind, { influencer: 0, media: 1 }

  # Nano : 1_10.000
  # Mikro : >10.000 - 100.000
  # Makro : >100.000 - 1.000.000
  # Mega : >1.000.000
  enum :size, { nano: 0, micro: 1, macro: 2, mega: 3 }

  # To skip fetch automatically
  attribute :manual, :boolean

  # Callbacks
  before_save :set_size, :set_estimated_engagement_rate_average
  after_create :fetch_and_populate_sosmed_data, :set_size, :set_estimated_engagement_rate_average

  # aliases
  alias_attribute :name, :username

  def self.ransackable_attributes(auth_object = nil)
    ["comment_price", "created_at", "discarded_at", "estimated_comments_count", "estimated_engagement_rate", "estimated_engagement_rate_average", "estimated_engagement_rate_branding_post", "estimated_impression", "estimated_likes_count", "estimated_reach", "estimated_share_count", "feed_photo_price", "feed_video_price", "followers", "host_price", "id", "id_value", "influencer_id", "kind", "last_sync_at", "link_in_bio_price", "live_attendance_price", "live_price", "name", "other_price", "owning_asset_price", "photoshoot_price", "platform", "platform_user_identifier", "reel_price", "size", "story_price", "story_session_price", "tap_link_price", "updated_at", "username"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["categories", "influencer", "managements", "media_plans", "payment_requests", "profile_picture_attachment", "profile_picture_blob", "scope_of_works"]
  end

  def platform_url
    if platform == 'instagram'
      "https://instagram.com/#{username}"
    elsif platform == 'tiktok'
      "https://tiktok.com/@#{username}"
    end
  end

  def fetch_and_populate_sosmed_data
    return if manual

    case platform
    when 'instagram'
      fetch_and_populate_instagram_data
    when 'tiktok'
      fetch_and_populate_tiktok_data
    end
  end

  def fetch_and_populate_instagram_data
    active_instagram_profile = ActiveInstagram.profile_by_username(username)
    user = active_instagram_profile.user

    # It's a shame that profile endpoint returns both user info and medias,
    # but it doesn't return video_view_count for each media :(
    posts = ActiveInstagram.medias_by_user_id(user.id)

    # attach profile picture from instagram
    if user.profile_picture.present?
      file = URI.open user.profile_picture, "Access-Control-Allow-Origin" => "*", "Access-Control-Allow-Headers" => "*"
      self.profile_picture.attach(io: file, filename: "ig_#{username}.jpg", content_type: 'image/jpeg')
    end

    # Calculate estimated metrics
    ig_calculator = InstagramMetricsCalculatorService.new(posts: posts, user: user)

    self.update(followers: user.followed_by_count,
                platform_user_identifier: user.id,
                estimated_impression: ig_calculator.estimated_impression,
                estimated_reach: ig_calculator.estimated_reach,
                estimated_engagement_rate: ig_calculator.estimated_engagement_rate,
                estimated_comments_count: ig_calculator.estimated_comments_count,
                estimated_likes_count: ig_calculator.estimated_likes_count,
                last_sync_at: Time.now
               )
  end

  def fetch_and_populate_tiktok_data
    active_tiktok_user = ActiveTiktok.user_by_username(username)
    active_tiktok_posts = ActiveTiktok.medias_by_user_id(active_tiktok_user.id)
    tiktok_metrics_calculator = TiktokMetricsCalculatorService.new(posts: active_tiktok_posts, user: active_tiktok_user)

    # attach profile picture from TikTok
    if active_tiktok_user.profile_picture.present?
      file = URI.open active_tiktok_user.profile_picture, "Access-Control-Allow-Origin" => "*", "Access-Control-Allow-Headers" => "*"
      self.profile_picture.attach(io: file, filename: "tiktok_#{username}.jpg", content_type: 'image/jpeg')
    end

    self.update(
      followers: active_tiktok_user.followed_by_count,
      platform_user_identifier: active_tiktok_user.id,
      estimated_impression: tiktok_metrics_calculator.estimated_impression,
      estimated_reach: tiktok_metrics_calculator.estimated_reach,
      estimated_engagement_rate: tiktok_metrics_calculator.estimated_engagement_rate,
      last_sync_at: Time.now,
      estimated_comments_count: tiktok_metrics_calculator.estimated_comments_count,
      estimated_likes_count: tiktok_metrics_calculator.estimated_likes_count,
      estimated_share_count: tiktok_metrics_calculator.estimated_share_count
    )
  end

  def set_size
    self.followers ||= 0

    self.size = if followers < 10_000
      'nano'
    elsif followers < 100_000
      'micro'
    elsif followers < 1_000_000
      'macro'
    else
      'mega'
    end
  end

  def set_estimated_engagement_rate_average
    self.estimated_engagement_rate_average = (estimated_engagement_rate + estimated_engagement_rate_branding_post) / 2
  end

  def estimated_total_engagement
    [
      estimated_likes_count,
      estimated_comments_count,
      estimated_share_count
    ].compact.map(&:to_i).sum
  end

  ###
  # Costs related
  ###

  # it picks the highest price from all prices
  def cost
    prices = %i[
      story_price story_session_price
      feed_photo_price feed_video_price
      reel_price live_price owning_asset_price
      tap_link_price link_in_bio_price live_attendance_price
      host_price comment_price photoshoot_price
      other_price
    ]

    prices.map { |price| send(price) }.max
  end

  def cpv
    return 0 if estimated_impression.to_i.zero? || cost&.zero?

    cost / estimated_impression
  end

  def cpe
    total_engagement = estimated_total_engagement.to_i
    total_cost = cost.to_f

    # Early returns for invalid cases
    return 0 if total_engagement <= 0  # Handles zero and negative cases
    return 0 if total_cost <= 0        # Handles zero and negative cases
    return 0 unless total_cost.finite? # Handles infinity

    result = (total_cost / total_engagement).to_i

    # Final safety check
    result.is_a?(Integer) && result.finite? ? result : 0
  rescue StandardError => e
    Rails.logger.error "CPE calculation error for account #{username}: #{e.message}"
    0
  end

  def cpr
    return 0 if estimated_reach.to_i.zero? || cost&.zero?

    cost.to_f / estimated_reach.to_f
  end

  # It returns 40% from the followers
  def gross_estimated_reach
    return 0 if followers.blank?

    (followers * 0.4).to_i
  end
end
