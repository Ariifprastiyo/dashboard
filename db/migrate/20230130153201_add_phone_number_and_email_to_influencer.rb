class AddPhoneNumberAndEmailToInfluencer < ActiveRecord::Migration[7.0]
  def change
    add_column :influencers, :phone_number, :string
    add_column :influencers, :email, :string
  end
end
