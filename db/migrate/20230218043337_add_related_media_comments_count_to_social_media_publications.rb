class AddRelatedMediaCommentsCountToSocialMediaPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_publications, :related_media_comments_count, :bigint, default: 0, null: false
  end
end
