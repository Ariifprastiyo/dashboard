class AddPersonalInfoToInfluencers < ActiveRecord::Migration[7.0]
  def change
    add_column :influencers, :no_ktp, :string
    add_column :influencers, :no_npwp, :string
    add_column :influencers, :bank_code, :string
    add_column :influencers, :account_number, :string
    add_column :influencers, :address, :text
  end
end
