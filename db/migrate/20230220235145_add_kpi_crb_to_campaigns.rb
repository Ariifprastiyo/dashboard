class AddKpiCrbToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :kpi_crb, :decimal, null: false, default: 0
  end
end
