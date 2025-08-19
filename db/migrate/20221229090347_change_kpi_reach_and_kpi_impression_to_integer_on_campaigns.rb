class ChangeKpiReachAndKpiImpressionToIntegerOnCampaigns < ActiveRecord::Migration[7.0]
  def change
    change_column :campaigns, :kpi_reach, :integer, default: 0
    change_column :campaigns, :kpi_impression, :integer, default: 0
  end
end
