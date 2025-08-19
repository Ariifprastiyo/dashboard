class AddCommentsCountToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :media_comments_count, :bigint, null: false, default: 0
    add_column :campaigns, :related_media_comments_count, :bigint, null: false, default: 0
  end
end
