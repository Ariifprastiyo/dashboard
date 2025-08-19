class AddAdditionalInfoToSocialMediaPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_publications, :additional_info, :text
  end
end
