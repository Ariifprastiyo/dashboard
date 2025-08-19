class AddManagementToScopeOfWork < ActiveRecord::Migration[7.0]
  def change
    add_reference :scope_of_works, :management, null: true, foreign_key: true
  end
end
