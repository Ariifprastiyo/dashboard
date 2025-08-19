class AddOrganizationIdToBrands < ActiveRecord::Migration[7.1]
  def change
    add_reference :brands, :organization, null: true, foreign_key: true
  end
end
