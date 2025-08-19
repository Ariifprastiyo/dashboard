class ChangePricesOnSocialMediaAccountsFromIntegerToBigInt < ActiveRecord::Migration[7.1]
  def change
    change_column :social_media_accounts, :story_price, :bigint, default: 0
    change_column :social_media_accounts, :story_session_price, :bigint, default: 0
    change_column :social_media_accounts, :feed_photo_price, :bigint, default: 0
    change_column :social_media_accounts, :feed_video_price, :bigint, default: 0
    change_column :social_media_accounts, :reel_price, :bigint, default: 0
    change_column :social_media_accounts, :live_price, :bigint, default: 0
    change_column :social_media_accounts, :owning_asset_price, :bigint, default: 0
    change_column :social_media_accounts, :host_price, :bigint, default: 0
    change_column :social_media_accounts, :comment_price, :bigint, default: 0
    change_column :social_media_accounts, :photoshoot_price, :bigint, default: 0
    change_column :social_media_accounts, :other_price, :bigint, default: 0
  end
end
