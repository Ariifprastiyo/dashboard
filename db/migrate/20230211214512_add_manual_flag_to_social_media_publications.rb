class AddManualFlagToSocialMediaPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_publications, :manual, :boolean, default: false
  end
end
