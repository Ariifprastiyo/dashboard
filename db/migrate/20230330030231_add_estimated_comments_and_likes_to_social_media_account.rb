class AddEstimatedCommentsAndLikesToSocialMediaAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_accounts, :estimated_likes_count, :integer
    add_column :social_media_accounts, :estimated_comments_count, :integer
    add_column :social_media_accounts, :estimated_share_count, :integer
  end
end
