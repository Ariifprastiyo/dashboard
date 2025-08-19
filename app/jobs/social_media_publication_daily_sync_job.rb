# frozen_string_literal: true

class SocialMediaPublicationDailySyncJob < ApplicationJob
  queue_as :default

  include GoodJob::ActiveJobExtensions::Concurrency

  # Actually the limit is 180 per-minute, BUT this job will generate another job to run and thus hit the limit.
  good_job_control_concurrency_with(perform_throttle: [2, 1.second])


  def perform(social_media_publication_id)
    social_media_publication = SocialMediaPublication.find(social_media_publication_id)
    social_media_publication.sync_daily_update(raise_exception: true)
  end
end
