class AddDiscardedAtToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :discarded_at, :datetime
    add_index :campaigns, :discarded_at
  end
end
