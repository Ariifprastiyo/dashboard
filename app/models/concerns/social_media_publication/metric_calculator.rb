# frozen_string_literal: true

# This module handles everything related to metrics
# This can be used only for SocialMediaPublication class only
module SocialMediaPublication::MetricCalculator
  extend ActiveSupport::Concern

  included do
    raise 'Only for SocialMediaPublication class' unless self.name == 'SocialMediaPublication'

    # cache metrics callbacks
    after_create :recalculate_metrics, if: :campaign
    after_destroy :recalculate_metrics, if: :campaign
    after_update :recalculate_metrics, if: :campaign

    # delegate to scope_of_work_item
    delegate :sell_price, to: :scope_of_work_item
  end

  def recalculate_metrics
    self.campaign.recalculate_metrics
    self.scope_of_work.recalculate_metrics
  end

  def total_engagement
    likes_count + comments_count + share_count + saves_count
  end

  def comment_related_to_brand_percentage
    return 0 if media_comments_count.zero?

    related_media_comments_count.to_f / media_comments.count.to_f * 100
  end

  ###
  # Costs related
  ###

  def cpv
    return 0 if impressions.zero? || sell_price.nil?

    sell_price / impressions
  end

  def cpr
    return 0 if reach.zero? || sell_price.nil?

    sell_price / reach
  end

  def cpe
    return 0 if total_engagement.zero? || sell_price.nil?

    sell_price / total_engagement
  end
end
