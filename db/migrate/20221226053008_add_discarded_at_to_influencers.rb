class AddDiscardedAtToInfluencers < ActiveRecord::Migration[7.0]
  def change
    add_column :influencers, :discarded_at, :datetime
    add_index :influencers, :discarded_at
  end
end
