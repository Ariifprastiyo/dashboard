class ChangeCostsBasedKpisToInteger < ActiveRecord::Migration[7.1]
  def up
    change_column :campaigns, :kpi_cpr, :integer, default: 0
    change_column :campaigns, :kpi_cpv, :integer, default: 0
    change_column :campaigns, :kpi_cpe, :integer, default: 0
  end

  def down
    change_column :campaigns, :kpi_cpr, :decimal
    change_column :campaigns, :kpi_cpv, :decimal
    change_column :campaigns, :kpi_cpe, :decimal
  end
end
