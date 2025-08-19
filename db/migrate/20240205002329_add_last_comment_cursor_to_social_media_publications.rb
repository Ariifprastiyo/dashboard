class AddLastCommentCursorToSocialMediaPublications < ActiveRecord::Migration[7.1]
  def change
    add_column :social_media_publications, :last_comment_cursor, :string
  end
end
