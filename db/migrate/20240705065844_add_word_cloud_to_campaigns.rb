class AddWordCloudToCampaigns < ActiveRecord::Migration[7.1]
  def change
    add_column :campaigns, :word_cloud, :json
    add_column :campaigns, :word_cloud_payload_result, :text
  end
end
