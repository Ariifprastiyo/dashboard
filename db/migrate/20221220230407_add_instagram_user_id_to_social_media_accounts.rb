class AddInstagramUserIdToSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_accounts, :user_id, :integer
  end
end
