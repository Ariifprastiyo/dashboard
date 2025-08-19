class AddSavesCountToPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_publications, :saves_count, :bigint, null: false, default: 0
  end
end
