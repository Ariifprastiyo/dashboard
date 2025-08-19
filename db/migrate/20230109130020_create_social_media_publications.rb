class CreateSocialMediaPublications < ActiveRecord::Migration[7.0]
  def change
    create_table :social_media_publications do |t|
      t.string :post_identifier
      t.integer :platform
      t.integer :kind
      t.string :url
      t.datetime :post_created_at
      t.text :caption
      t.integer :comments_count
      t.integer :likes_count
      t.integer :share_count
      t.integer :impressions
      t.integer :reach
      t.float :engagement_rate
      t.datetime :last_sync_at
      t.jsonb :payload
      t.references :social_media_account
      t.timestamps
    end
  end
end
