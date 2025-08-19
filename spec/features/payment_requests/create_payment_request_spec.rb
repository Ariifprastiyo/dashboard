require 'rails_helper'

RSpec.describe 'Campaign::CreatePaymentRequest' do
  let(:campaign) { create(:campaign) }
  let(:media_plan) { create(:media_plan, :empty, campaign: campaign) }
  let(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'images', 'logo.png') }

  before do
    campaign.update(selected_media_plan: media_plan)
    admin = create(:admin)
    admin.add_role(:super_admin)
    sign_in admin
  end

  it 'returns success response' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)

    visit campaigns_payment_requests_new_path(id: campaign.id)

    select social_media_account.username, from: :payment_request_beneficiary_sgid

    # Expect remaining amount to be shown
    expect(page).to have_content 'Remaining amount that needs to be paid'
    expect(page).to have_content 'Rp 10.000.000'

    fill_in :payment_request_due_date, with: '2020-10-10'
    fill_in :payment_request_amount, with: '10000000'
    attach_file :payment_request_invoice, file_path
    fill_in :payment_request_notes, with: 'first payment request'
    click_on 'Buat Payment request'
    expect(page).to have_content 'Payment request has been created'
  end

  it 'returns error response when amount was blank' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)

    visit campaigns_payment_requests_new_path(id: campaign.id)

    select social_media_account.username, from: :payment_request_beneficiary_sgid

    # Expect remaining amount to be shown
    expect(page).to have_content 'Rp 10.000.000'

    fill_in :payment_request_due_date, with: '2020-10-10'
    fill_in :payment_request_amount, with: nil
    attach_file :payment_request_invoice, file_path
    fill_in :payment_request_notes, with: 'first payment request'

    # simulate no html validation
    page.execute_script("document.getElementById('new_payment_request').noValidate = true;")

    click_on 'Buat Payment request'
    expect(page).to have_content 'tidak boleh kosong'
  end
end
