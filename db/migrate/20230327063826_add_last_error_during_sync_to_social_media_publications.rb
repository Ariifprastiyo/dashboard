class AddLastErrorDuringSyncToSocialMediaPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_publications, :last_error_during_sync, :string
  end
end
