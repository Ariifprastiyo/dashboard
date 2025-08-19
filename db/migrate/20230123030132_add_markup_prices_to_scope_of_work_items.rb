class AddMarkupPricesToScopeOfWorkItems < ActiveRecord::Migration[7.0]
  def change
    add_column :scope_of_work_items, :sell_price, :decimal
    add_column :scope_of_work_items, :subtotal_sell_price, :decimal
  end
end
