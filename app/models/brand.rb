# frozen_string_literal: true

class Brand < ApplicationRecord
  include Discard::Model

  belongs_to :organization, optional: true
  has_many :campaigns, dependent: :destroy

  # ATTENTION, ActiveRecord magic that makes your life easier
  # This association creates a shortcut to access selected media plans for a brand.
  # It works by:
  # 1. Going through the brand's campaigns
  # 2. For each campaign, finding the associated media plan via the 'selected_media_plan' method
  # 3. Collecting all these media plans into a single collection
  # This allows you to easily get all selected media plans for a brand with 'brand.selected_media_plans'
  has_many :selected_media_plans, through: :campaigns, source: :selected_media_plan

  has_many :selected_scope_of_works, through: :selected_media_plans, source: :scope_of_works
  has_many :social_media_publications, through: :campaigns

  validates :name, presence: true, uniqueness: true
  validates :logo, content_type: %w[image/png image/jpg image/jpeg], size: { less_than: 10.megabyte }

  has_one_attached :logo, dependent: :destroy do |attachable|
    attachable.variant :default, resize_to_limit: [100, 100]
    attachable.variant :thumb, resize_to_limit: [50, 50]
  end

  # Total posts from all campaigns
  def total_social_media_publications
    social_media_publications.count
  end

  # Total reach from all campaigns
  def total_reach
    campaigns.sum(:reach)
  end

  # Total Engagement from all campaigns
  def total_engagement
    campaigns.sum(:likes_count) + campaigns.sum(:comments_count) + campaigns.sum(:share_count)
  end

  # Total investment from all campaigns
  def total_investment
    selected_scope_of_works.sum(:budget_spent_sell_price)
  end

  # ransack
  def self.ransackable_associations(auth_object = nil)
    ["campaigns", "organization", "selected_media_plans"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "description", "instagram", "tiktok", "discarded_at", "organization_id", "created_at", "updated_at"]
  end
end
