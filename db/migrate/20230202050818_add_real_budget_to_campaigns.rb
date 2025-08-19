class AddRealBudgetToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :budget_from_brand, :integer, default: 0
    change_column :campaigns, :budget, :integer, default: 0
  end
end
