# frozen_string_literal: true

class CancelBulkPublicationJob < ApplicationJob
  def perform(job_id)
    return unless cancelled?

    bulk_publication = BulkPublication.find_by(job_id: job_id)
    bulk_publication&.update(cancelled_at: Time.now)
  end

  def cancelled?
    # Sidekiq.redis { |c| c.exists("cancelled-#{jid}") } # Use c.exists? on Redis >= 4.2.0
  end

  def self.cancel!(jid)
    # Sidekiq.redis { |c| c.setex("cancelled-#{jid}", 30, 1) }
  end
end
