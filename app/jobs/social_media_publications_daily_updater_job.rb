# frozen_string_literal: true

# It is similar to the SocialMediaPublicationUpdaterJob, but it is used to sync the daily update of a social media publication individually.
# NOTE that only either SocialMediaPublicationUpdaterJob or SocialMediaPublicationsDailyUpdaterJob can be used at the same time.
class SocialMediaPublicationsDailyUpdaterJob < ApplicationJob
  queue_as :default

  def perform(*args)
    social_media_publications = SocialMediaPublication.need_sync_daily_update
    social_media_publications.each do |social_media_publication|
      SocialMediaPublicationDailySyncJob.perform_later(social_media_publication.id)
    end
  end
end
