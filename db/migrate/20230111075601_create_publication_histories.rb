class CreatePublicationHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :publication_histories do |t|
      t.references :social_media_publication, null: false, foreign_key: true
      t.integer :likes_count
      t.integer :comments_count
      t.integer :impressions
      t.integer :reach
      t.float :engagement_rate
      t.integer :share_count

      t.timestamps
    end
  end
end
