class AddDiscardedAtToSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_accounts, :discarded_at, :datetime
    add_index :social_media_accounts, :discarded_at
  end
end
