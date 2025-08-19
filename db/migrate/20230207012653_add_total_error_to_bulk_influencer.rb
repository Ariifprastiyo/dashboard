class AddTotalErrorToBulkInfluencer < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_influencers, :total_error, :integer
  end
end
