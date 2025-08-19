# frozen_string_literal: true

class SingleSocialMediaPublicationUpdaterJob < ApplicationJob
  queue_as :default

  def perform(*args)
    publication = SocialMediaPublication.find(args[0])
    publication.sync_daily_update(force: true)
  end
end
