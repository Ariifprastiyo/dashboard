class AddCampaignIdToSocialMediaPublications < ActiveRecord::Migration[7.0]
  def change
    add_reference :social_media_publications, :campaign, null: false, foreign_key: true
  end
end
