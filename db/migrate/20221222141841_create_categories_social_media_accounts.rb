class CreateCategoriesSocialMediaAccounts < ActiveRecord::Migration[7.0]
  def change
    create_join_table :categories, :social_media_accounts
  end
end
