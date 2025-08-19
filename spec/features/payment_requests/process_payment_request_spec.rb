require 'rails_helper'

RSpec.describe 'Campaign::ProcessPaymentRequest', type: :feature do
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

  it 'returns success response when gross up and dont have ppn' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    payment_request = create(:payment_request, :pending, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    fill_in :payment_request_notes, with: 'Paid request notes'
    select 'Gross Up', from: :payment_request_pph_option
    select 'Tidak ada', from: :payment_request_ppn

    # Expect remaining amount to be paid to 0
    expect(page).to have_content 'Remaining amount that needs to be paid'
    expect(page).to have_content 'Rp 0'

    within '#payment_request_total_ppn' do
      expect(page).to have_content 'Rp 0'
    end

    within '#payment_request_total_payment' do
      expect(page).to have_content 'Rp 10.000.000'
    end

    accept_confirm do
      click_on 'Process'
    end

    success_message = "Payment request to #{payment_request.beneficiary_name} for Rp10.000.000 has been processed"
    expect(page).to have_content success_message
  end

  it 'returns success response when choose net and dont have ppn' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    payment_request = create(:payment_request, :pending, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    fill_in :payment_request_notes, with: 'Paid request notes'
    select 'Dipotong', from: :payment_request_pph_option
    fill_in :payment_request_total_pph, with: 1_000_000
    select 'Tidak ada', from: :payment_request_ppn

    within '#payment_request_total_ppn' do
      expect(page).to have_content 'Rp 0'
    end

    within '#payment_request_total_payment' do
      expect(page).to have_content 'Rp 9.000.000'
    end

    accept_confirm do
      click_on 'Process'
    end

    success_message = "Payment request to #{payment_request.beneficiary_name} for Rp9.000.000 has been processed"
    expect(page).to have_content success_message
  end

  it 'returns success response when choose gross and have ppn' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    payment_request = create(:payment_request, :pending, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    fill_in :payment_request_notes, with: 'Paid request notes'
    select 'Gross Up', from: :payment_request_pph_option
    select 'Ada', from: :payment_request_ppn
    fill_in :payment_request_tax_invoice_number, with: 'INV-023'

    within '#payment_request_total_ppn' do
      expect(page).to have_content 'Rp 1.100.000'
    end

    within '#payment_request_total_payment' do
      expect(page).to have_content 'Rp 11.100.000'
    end

    accept_confirm do
      click_on 'Process'
    end

    success_message = "Payment request to #{payment_request.beneficiary_name} for Rp11.100.000 has been processed"
    expect(page).to have_content success_message
  end

  it 'returns success response when choose nett and have ppn', retry: 3 do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    payment_request = create(:payment_request, :pending, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    fill_in :payment_request_notes, with: 'Paid request notes'
    select 'Dipotong', from: :payment_request_pph_option
    fill_in :payment_request_total_pph, with: 1_000_000
    select 'Ada', from: :payment_request_ppn
    fill_in :payment_request_tax_invoice_number, with: 'INV-023'

    within '#payment_request_total_ppn' do
      expect(page).to have_content 'Rp 1.100.000'
    end

    within '#payment_request_total_payment' do
      expect(page).to have_content 'Rp 10.100.000'
    end

    accept_confirm do
      click_on 'Process'
    end

    success_message = "Payment request to #{payment_request.beneficiary_name} for Rp10.100.000 has been processed"
    expect(page).to have_content success_message
  end
end
