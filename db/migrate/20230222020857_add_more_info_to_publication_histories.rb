class AddMoreInfoToPublicationHistories < ActiveRecord::Migration[7.0]
  def change
    add_column :publication_histories, :social_media_account_id, :integer
    add_column :publication_histories, :social_media_account_size, :integer
    add_column :publication_histories, :platform, :integer
    add_column :publication_histories, :campaign_id, :integer
  end
end
