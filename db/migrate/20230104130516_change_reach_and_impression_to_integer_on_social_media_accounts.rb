class ChangeReachAndImpressionToIntegerOnSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    change_column :social_media_accounts, :estimated_impression, :integer, default: 0
    change_column :social_media_accounts, :estimated_reach, :integer, default: 0
  end
end
