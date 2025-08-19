class CreateManagementsAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :managements_accounts do |t|
      t.belongs_to :management
      t.belongs_to :social_media_account
      t.timestamps
    end
  end
end
