class RemoveCampaignIdFkConstraintsFromSocialMediaPublications < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :social_media_publications, to_table: :campaigns
    change_column_null :social_media_publications, :campaign_id, true
  end
end

