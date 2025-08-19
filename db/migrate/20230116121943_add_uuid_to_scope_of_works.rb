class AddUuidToScopeOfWorks < ActiveRecord::Migration[7.0]
  def change
    add_column :scope_of_works, :uuid, :uuid
  end
end
