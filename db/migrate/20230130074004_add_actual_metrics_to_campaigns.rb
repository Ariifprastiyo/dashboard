class AddActualMetricsToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :comments_count, :integer, default: 0
    add_column :campaigns, :likes_count, :integer, default: 0
    add_column :campaigns, :share_count, :integer, default: 0
    add_column :campaigns, :impressions, :integer, default: 0
    add_column :campaigns, :reach, :integer, default: 0
    add_column :campaigns, :engagement_rate, :float, default: 0
  end
end
