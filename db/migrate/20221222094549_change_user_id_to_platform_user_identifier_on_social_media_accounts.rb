class ChangeUserIdToPlatformUserIdentifierOnSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    rename_column :social_media_accounts, :user_id, :platform_user_identifier
    change_column :social_media_accounts, :platform_user_identifier, :string
  end
end
