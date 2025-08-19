class CreateOrganizationSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :organization_settings do |t|
      t.string :name

      t.timestamps
    end

    OrganizationSetting.create!(name: "MediaRumu")
  end
end
