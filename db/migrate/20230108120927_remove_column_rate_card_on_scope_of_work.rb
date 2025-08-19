class RemoveColumnRateCardOnScopeOfWork < ActiveRecord::Migration[7.0]
  def change
    remove_column :scope_of_works, :rate_card
  end
end
