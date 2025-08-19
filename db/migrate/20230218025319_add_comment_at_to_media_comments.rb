class AddCommentAtToMediaComments < ActiveRecord::Migration[7.0]
  def change
    add_column :media_comments, :comment_at, :datetime
  end
end
