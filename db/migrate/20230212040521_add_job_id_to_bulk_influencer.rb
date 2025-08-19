class AddJobIdToBulkInfluencer < ActiveRecord::Migration[7.0]
  def change
    add_column :bulk_influencers, :job_id, :string
  end
end
