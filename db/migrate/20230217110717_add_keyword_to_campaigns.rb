class AddKeywordToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :keyword, :text
    add_column :campaigns, :hashtag, :text
  end
end
