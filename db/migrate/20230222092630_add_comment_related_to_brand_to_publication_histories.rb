class AddCommentRelatedToBrandToPublicationHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :publication_histories, :related_media_comments_count, :integer, default: 0
  end
end
