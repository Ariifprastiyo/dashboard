class RenameColumnPhoneToPicPhoneNumberOnInfluencer < ActiveRecord::Migration[7.0]
  def change
    rename_column :influencers, :phone, :pic_phone_number
  end
end
