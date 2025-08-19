class CreateBulkPublications < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_publications do |t|
      t.references :campaign, null: false, foreign_key: true
      t.integer :total_row
      t.integer :current_row
      t.string :error_messages, array: true

      t.timestamps
    end
  end
end
