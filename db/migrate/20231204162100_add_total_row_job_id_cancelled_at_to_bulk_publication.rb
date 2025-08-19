class AddTotalRowJobIdCancelledAtToBulkPublication < ActiveRecord::Migration[7.1]
  def change
    add_column :bulk_publications, :cancelled_at, :datetime
    add_column :bulk_publications, :job_id, :string
    add_column :bulk_publications, :total_error, :integer
  end
end
