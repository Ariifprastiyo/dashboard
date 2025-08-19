class ChangeKpiReachAndKpiImpressionToIntegerOnMediaPlans < ActiveRecord::Migration[7.0]
  def change
    change_column :media_plans, :estimated_reach, :integer, default: 0
    change_column :media_plans, :estimated_impression, :integer, default: 0
    change_column :media_plans, :estimated_engagement_rate, :float, default: 0.0, null: false
    change_column :media_plans, :estimated_engagement_rate_branding_post, :float, default: 0.0, null: false
    change_column :media_plans, :estimated_budget, :decimal, default: 0.0, null: false
  end
end
