class ChangeScopeOfWorkItemsFromIntegerToBigint < ActiveRecord::Migration[7.1]
  def change
    change_column :scope_of_work_items, :quantity, :bigint, default: 0
    change_column :scope_of_work_items, :price, :bigint, default: 0
    change_column :scope_of_work_items, :subtotal, :bigint, default: 0
    change_column :scope_of_work_items, :sell_price, :bigint, default: 0
    change_column :scope_of_work_items, :subtotal_sell_price, :bigint, default: 0
  end
end
