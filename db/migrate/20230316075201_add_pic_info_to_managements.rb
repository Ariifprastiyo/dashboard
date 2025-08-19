class AddPicInfoToManagements < ActiveRecord::Migration[7.0]
  def change
    add_column :managements, :pic_name, :string
    add_column :managements, :pic_email, :string
  end
end
