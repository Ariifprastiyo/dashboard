class AddSelectedMediaPlanToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :selected_media_plan_id, :integer
  end
end
