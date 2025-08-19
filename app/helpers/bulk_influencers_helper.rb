# frozen_string_literal: true

module BulkInfluencersHelper
  def bulk_influencer_progress(bulk_influencer)
    total = bulk_influencer.total_row || 0
    current = bulk_influencer.current_row || 0

    progress = (current / total) * 100

    progress
  end
end
