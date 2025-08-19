class ChangePricesToIntegerFromScopeOfWorks < ActiveRecord::Migration[7.0]
  def change
    change_column :scope_of_works, :total, :integer
    change_column :scope_of_works, :total_sell_price, :integer
  end
end
