class AddDiscardedAtToManagements < ActiveRecord::Migration[7.0]
  def change
    add_column :managements, :discarded_at, :datetime
    add_index :managements, :discarded_at
  end
end
