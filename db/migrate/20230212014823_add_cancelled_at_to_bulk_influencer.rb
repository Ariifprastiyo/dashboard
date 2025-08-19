class AddCancelledAtToBulkInfluencer < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_influencers, :cancelled_at, :datetime
  end
end
