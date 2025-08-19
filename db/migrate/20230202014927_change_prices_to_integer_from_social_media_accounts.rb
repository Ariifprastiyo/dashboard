class ChangePricesToIntegerFromSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    ScopeOfWorkItem::PRICES.each do |price|
      change_column :social_media_accounts, "#{price}_price", :integer
    end
  end
end
