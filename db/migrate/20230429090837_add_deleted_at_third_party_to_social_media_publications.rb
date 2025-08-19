class AddDeletedAtThirdPartyToSocialMediaPublications < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_publications, :deleted_by_third_party, :boolean, default: false
  end
end
