require 'rails_helper'

RSpec.describe 'Campaign::PayPaymentRequest', type: :feature do
  let(:campaign) { create(:campaign) }
  let(:media_plan) { create(:media_plan, :empty, campaign: campaign) }
  let(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'images', 'logo.png') }
  let(:pdf_file_path) { Rails.root.join('spec', 'fixtures', 'files', 'hello.pdf') }

  before do
    campaign.update(selected_media_plan: media_plan)
    admin = create(:admin)
    admin.add_role(:super_admin)
    sign_in admin
  end

  it 'validates payment proof' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    create(:payment_request, :processed, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    within '#payment-actions' do
      accept_confirm do
        click_on 'Pay'
      end
    end

    error_message = "Payment proof tidak boleh kosong"
    expect(page).to have_content error_message
  end

  it 'returns success' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    create(:payment_request, :processed, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    fill_in :payment_request_notes, with: 'Paid request notes'
    attach_file :payment_request_payment_proof, file_path

    # Expect remaining amount to be paid to 0
    expect(page).to have_content 'Remaining amount that needs to be paid'
    expect(page).to have_content 'Rp 0'

    within '#payment-actions' do
      accept_confirm do
        click_on 'Pay'
      end
    end

    success_message = "Payment request is successfully paid"
    expect(page).to have_content success_message
  end

  it 'returns success when upload pdf file' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    create(:payment_request, :processed, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000, invoice: Rack::Test::UploadedFile.new(pdf_file_path, 'application/pdf'))
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    fill_in :payment_request_notes, with: 'Paid request notes'
    attach_file :payment_request_payment_proof, pdf_file_path

    # Expect remaining amount to be paid to 0
    expect(page).to have_content 'Remaining amount that needs to be paid'
    expect(page).to have_content 'Rp 0'

    within '#payment-actions' do
      accept_confirm do
        click_on 'Pay'
      end
    end

    success_message = "Payment request is successfully paid"
    expect(page).to have_content success_message

    click_on 'Lihat'

    # Show download file link for invoice and payment proof
    expect(page).to have_link 'Download file', count: 2
  end

  it 'shows correct informations' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    create(:payment_request, :processed, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000, ppn: true, pph_option: 'nett', total_pph: 1_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    within '#payment_request_total_ppn' do
      expect(page).to have_content 'Rp 1.100.000'
    end

    within '#payment_request_total_pph' do
      expect(page).to have_content 'Rp 1.000.000'
    end

    within '#payment_request_total_payment' do
      expect(page).to have_content 'Rp 10.100.000'
    end
  end

  it 'allows to reject payment requests' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    payment_request = create(:payment_request, :processed, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    fill_in :payment_request_notes, with: 'Reject message'

    accept_confirm do
      click_on 'Reject'
    end

    success_message = "Payment request to #{payment_request.beneficiary_name} for Rp10.000.000 has been rejected"
    expect(page).to have_content success_message
  end
end
