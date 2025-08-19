class CreateManagements < ActiveRecord::Migration[7.0]
  def change
    create_table :managements do |t|
      t.string :name
      t.string :phone
      t.string :no_ktp
      t.string :no_npwp
      t.string :bank_code
      t.string :account_number
      t.string :address

      t.timestamps
    end
  end
end
