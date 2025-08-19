# frozen_string_literal: true

class SocialMediaAccountUpdaterJob < ApplicationJob
  queue_as :default

  def perform(*args)
    social_media_accounts = SocialMediaAccount.where('last_sync_at < ?', 24.hours.ago)

    social_media_accounts.find_each(batch_size: 500) do |social_media_account|
      SingleSocialMediaAccountUpdaterJob.perform_later(social_media_account.id)
    end
  end
end
