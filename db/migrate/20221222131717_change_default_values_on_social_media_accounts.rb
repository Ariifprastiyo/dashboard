class ChangeDefaultValuesOnSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    # change default value to 0 for follwers, estimated_impression, estimated_reach, estimated_engagement_rate and estimated_engagement_rate_branding_post
    change_column_default :social_media_accounts, :followers, from: nil, to: 0
    change_column_default :social_media_accounts, :estimated_impression, from: nil, to: 0
    change_column_default :social_media_accounts, :estimated_reach, from: nil, to: 0
    change_column_default :social_media_accounts, :estimated_engagement_rate, from: nil, to: 0
    change_column_default :social_media_accounts, :estimated_engagement_rate_branding_post, from: nil, to: 0
  end
end
