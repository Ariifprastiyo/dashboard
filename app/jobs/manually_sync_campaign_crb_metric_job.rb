# frozen_string_literal: true

class ManuallySyncCampaignCrbMetricJob < ApplicationJob
  queue_as :manual_sync_media_comments_counter

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)

    # Retrieve media comments that have not been manually reviewed
    media_comments = campaign.media_comments.where(manually_reviewed_at: nil)

    media_comments.each do |media_comment|
      media_comment.sync_related_to_brand_flag
    end

    MediaComment.counter_culture_fix_counts
  end
end
