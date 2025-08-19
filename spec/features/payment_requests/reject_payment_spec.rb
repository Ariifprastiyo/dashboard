require 'rails_helper'

RSpec.describe 'PaymentRequests::RejectPayment', type: :feature do
  let(:campaign) { create(:campaign) }
  let(:media_plan) { create(:media_plan, :empty, campaign: campaign) }
  let(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }

  before do
    campaign.update(selected_media_plan: media_plan)
    admin = create(:admin)
    admin.add_role(:super_admin)
    sign_in admin
  end

  it 'returns success response when reject payment via review page' do
    sow = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
    create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000)
    payment_request = create(:payment_request, :pending, campaign: campaign, beneficiary: social_media_account, amount: 10_000_000)
    visit campaigns_payment_requests_path(id: campaign.id)

    click_on 'Lihat'

    accept_confirm do
      click_on 'Reject'
    end

    # Expect success message
    success_message = "Payment request to #{payment_request.beneficiary_name} for Rp10.000.000 has been rejected"

    expect(page).to have_content success_message
    expect(page).to have_content 'rejected'
  end
end
