class AddKpiCpeToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :kpi_cpe, :integer
  end
end
