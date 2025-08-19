class CreatePaymentRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :payment_requests do |t|
      t.integer :requestor_id
      t.integer :beneficiary_id
      t.string :beneficiary_type
      t.integer :amount
      t.date :due_date
      t.integer :status
      t.text :notes
      t.references :campaign, null: false, foreign_key: true
      t.date :paid_at
      t.integer :payer_id

      t.timestamps
    end
  end
end
