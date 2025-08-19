class ChangeDefaultValuesOfOwningAssetPriceOnSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    change_column_default :social_media_accounts, :owning_asset_price, from: nil, to: 0
  end
end
