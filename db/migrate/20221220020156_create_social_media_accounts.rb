class CreateSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :social_media_accounts do |t|
      t.references :influencer, null: false, foreign_key: true
      t.string :username
      t.integer :platform
      t.integer :followers
      t.decimal :story_price
      t.decimal :story_session_price
      t.decimal :feed_photo_price
      t.decimal :feed_video_price
      t.decimal :reel_price
      t.decimal :live_price
      t.decimal :owning_asset_price
      t.datetime :last_sync_at
      t.float :recent_engagement_rate
      t.float :estimated_impression
      t.float :estimated_reach
      t.float :estimated_engagement_rate
      t.float :estimated_engagement_rate_branding_post

      t.timestamps
    end
  end
end
