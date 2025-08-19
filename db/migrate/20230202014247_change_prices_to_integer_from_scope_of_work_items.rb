class ChangePricesToIntegerFromScopeOfWorkItems < ActiveRecord::Migration[7.0]
  def change
    # change prices fields from decimal to integer
    change_column :scope_of_work_items, :price, :integer
    change_column :scope_of_work_items, :subtotal, :integer
    change_column :scope_of_work_items, :sell_price, :integer
    change_column :scope_of_work_items, :subtotal_sell_price, :integer
  end
end
