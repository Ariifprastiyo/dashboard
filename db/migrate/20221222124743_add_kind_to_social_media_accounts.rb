class AddKindToSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :social_media_accounts, :kind, :integer
  end
end
