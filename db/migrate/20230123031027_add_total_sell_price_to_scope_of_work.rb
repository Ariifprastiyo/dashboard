class AddTotalSellPriceToScopeOfWork < ActiveRecord::Migration[7.0]
  def change
    add_column :scope_of_works, :total_sell_price, :decimal
  end
end
