# frozen_string_literal: true

# This job is used to sync SocialMediaPublication daily update in BATCH.
class SocialMediaPublicationUpdaterJob < ApplicationJob
  queue_as :default

  def perform(*args)
    social_media_publications = SocialMediaPublication.need_sync_daily_update

    social_media_publications.each_with_index do |social_media_publication, index|
      social_media_publication.sync_daily_update
    end
  end
end
