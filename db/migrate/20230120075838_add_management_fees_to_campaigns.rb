class AddManagementFeesToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :management_fees, :decimal
  end
end
