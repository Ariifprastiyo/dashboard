class AddEstimatedEngagementRateAverageAndRemoveRecentEngagementRateFromSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_accounts, :estimated_engagement_rate_average, :float, default: 0.0
    remove_column :social_media_accounts, :recent_engagement_rate
  end
end
