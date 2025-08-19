class ChangeTotalFromIntToBigintFromScopeOfWorks < ActiveRecord::Migration[7.1]
  def change
    change_column :scope_of_works, :total, :bigint
  end
end
