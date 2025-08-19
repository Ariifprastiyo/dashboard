class AddBudgetSpentOnScopeOfWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :scope_of_works, :budget_spent, :integer, default: 0
    add_column :scope_of_works, :budget_spent_sell_price, :integer, default: 0
  end
end
