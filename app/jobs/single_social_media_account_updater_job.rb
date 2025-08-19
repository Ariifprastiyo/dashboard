# frozen_string_literal: true

class SingleSocialMediaAccountUpdaterJob < ApplicationJob
  queue_as :default

  def perform(*args)
    social_media_account = SocialMediaAccount.find_by(id: args[0])

    if social_media_account.nil?
      Sentry.capture_message("SingleSocialMediaAccountUpdaterJob: No social media account found with id: #{args[0]}")
      return
    end

    social_media_account.fetch_and_populate_sosmed_data

    # Recalculate metrics for media plan that have this social media account
    if args[1].present?
      RecalculateMediaPlanMetricJob.perform_later(args[1])
    end
  end
end
