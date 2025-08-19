class AddPaymentTermsNoteToScopeOfWork < ActiveRecord::Migration[7.0]
  def change
    add_column :scope_of_works, :agreement_payment_terms_note, :string
    add_column :scope_of_works, :agreement_maximum_payment_day, :integer
    add_column :scope_of_works, :agreement_absent_day, :integer
    add_column :scope_of_works, :agreement_end_date, :date
  end
end
