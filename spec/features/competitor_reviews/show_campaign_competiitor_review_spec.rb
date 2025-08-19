require 'rails_helper'

RSpec.feature "CompetitorReviews::ShowCampaignCompetitorReview", type: :feature do
  let!(:super_admin) { create(:super_admin) }
  let!(:organization) { create(:organization, name: 'My Organization') }
  let!(:brand) { create(:brand, name: 'My Brand') }
  let!(:campaign) { create(:campaign, organization: organization, name: 'My Campaign') }

  # craete selected media_plan for campaing
  let!(:selected_media_plan) { create(:media_plan, campaign: campaign) }
  let!(:social_media_account) { create(:social_media_account, :instagram_mega_manual) }
  let!(:sow) { create(:scope_of_work, media_plan: selected_media_plan, social_media_account: social_media_account, reach: 1000, likes_count: 2000, share_count: 3000, comments_count: 4000, budget_spent_sell_price: 200_000) }
  let!(:sow_item) { create(:scope_of_work_item, scope_of_work: sow, quantity: 1, price: 10_000_000, subtotal: 10_000_000) }

  let!(:instagram_micro_manual) { create(:social_media_account, :instagram_micro_manual) }
  let!(:sow_micro) { create(:scope_of_work, media_plan: selected_media_plan, social_media_account: instagram_micro_manual, reach: 5000, likes_count: 1000, share_count: 1500, comments_count: 2000, budget_spent_sell_price: 100_000) }
  let!(:sow_item_micro) { create(:scope_of_work_item, scope_of_work: sow_micro, quantity: 1, price: 10_000_000, subtotal: 10_000_000) }

  let!(:competitor_review) { create(:competitor_review, organization: organization, campaigns: [campaign]) }

  before do
    campaign.update(selected_media_plan: selected_media_plan)

    sign_in super_admin
    visit show_campaign_competitor_review_path(competitor_review, campaign_id: campaign.id)
  end

  scenario 'super admin can see campaign summary by tier' do
    expect(page).to have_content('Campaign Summary by Influencer Tier')

    within('#campaign-summary-by-tier') do
      # Check table headers
      expect(page).to have_content('Tier')
      expect(page).to have_content('Total Accounts')
      expect(page).to have_content('Total Reach')
      expect(page).to have_content('Total Engagement')
      expect(page).to have_content('Total Est. Investment')

      # Check Nano tier
      within('tr', text: 'Nano') do
        expect(page).to have_content('0')
        expect(page).to have_content('0')
        expect(page).to have_content('0')
        expect(page).to have_content('Rp0')
      end

      # Check Micro tier
      within('tr', text: 'Micro') do
        expect(page).to have_content('1')
        expect(page).to have_content('5.000')
        expect(page).to have_content('4.500')
        expect(page).to have_content('Rp100.000')
      end

      # Check Macro tier
      within('tr', text: 'Macro') do
        expect(page).to have_content('0')
        expect(page).to have_content('0')
        expect(page).to have_content('0')
        expect(page).to have_content('Rp0')
      end

      # Check Mega tier
      within('tr', text: 'Mega') do
        expect(page).to have_content('1')
        expect(page).to have_content('1.000')
        expect(page).to have_content('9.000')
        expect(page).to have_content('Rp200.000')
      end

      # Check Total row
      within('tr.table-primary') do
        expect(page).to have_content('Total')
        expect(page).to have_content('2')
        expect(page).to have_content('6.000')
        expect(page).to have_content('13.500')
        expect(page).to have_content('Rp300.000')
      end
    end
  end
end
