class AddActualMetricsToScopeOfWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :scope_of_works, :comments_count, :integer, default: 0
    add_column :scope_of_works, :likes_count, :integer, default: 0
    add_column :scope_of_works, :share_count, :integer, default: 0
    add_column :scope_of_works, :impressions, :integer, default: 0
    add_column :scope_of_works, :reach, :integer, default: 0
    add_column :scope_of_works, :engagement_rate, :float, default: 0
  end
end
