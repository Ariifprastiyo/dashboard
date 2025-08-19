class AddUpdatedTargetPlanFoReachToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :updated_target_plan_for_reach, :json
  end
end
