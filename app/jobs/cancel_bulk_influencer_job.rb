# frozen_string_literal: true

class CancelBulkInfluencerJob < ApplicationJob
  def perform(job_id)
    if cancelled?
      bulk_influencer = BulkInfluencer.find_by(job_id: job_id)
      bulk_influencer.cancelled_at = Time.now
      bulk_influencer.save
    end
  end

  def cancelled?
    # Sidekiq.redis { |c| c.exists("cancelled-#{jid}") } # Use c.exists? on Redis >= 4.2.0
  end

  def self.cancel!(jid)
    # Sidekiq.redis { |c| c.setex("cancelled-#{jid}", 30, 1) }
  end
end
