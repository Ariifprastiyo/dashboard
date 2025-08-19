class CreateScopeOfWorkItems < ActiveRecord::Migration[7.0]
  def change
    create_table :scope_of_work_items do |t|
      t.references :scope_of_work, null: false, foreign_key: true
      t.string :name
      t.integer :quantity
      t.decimal :price
      t.decimal :subtotal

      t.timestamps
    end
  end
end
