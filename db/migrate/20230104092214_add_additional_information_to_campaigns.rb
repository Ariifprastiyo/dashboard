class AddAdditionalInformationToCampaigns < ActiveRecord::Migration[7.0]
  def change
    add_column :campaigns, :mediarumu_pic_name, :string
    add_column :campaigns, :mediarumu_pic_phone, :string
    add_column :campaigns, :notes_and_media_terms, :text
    add_column :campaigns, :payment_terms, :text
    add_column :campaigns, :client_sign_name, :string
  end
end
