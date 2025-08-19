class AddTotalPaymentToPaymentRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :payment_requests, :pph_option, :integer, default: 1
    add_column :payment_requests, :total_pph, :bigint, default: 0
    add_column :payment_requests, :ppn, :boolean, default: false
    add_column :payment_requests, :tax_invoice_number, :text
    add_column :payment_requests, :total_ppn, :bigint, default: 0
    add_column :payment_requests, :total_payment, :bigint, default: 0
  end
end
