require 'rails_helper'

RSpec.feature "Campaings::ListingCampaigs" do
  before do
    super_admin = create(:super_admin)
    sign_in super_admin
  end

  it 'returns expected data' do
    active_campaign = create(:campaign, :active)
    draft_campaign = create(:campaign, :draft)
    completed_campaign = create(:campaign, :completed)
    failed_campaign = create(:campaign, :failed)

    visit campaigns_path

    # Expect cards
    cards = [
      'ACTIVE campaigns',
      'DRAFT campaigns',
      'COMPLETED campaigns',
    ]
    cards.each do |card|
      expect(page).to have_content card
    end

    expect(page).to have_content active_campaign.name
    expect(page).to have_content draft_campaign.name

    # Hide completed campaigns by default
    expect(page).not_to have_content completed_campaign.name
    click_on 'Toggle campaigns'
    expect(page).to have_content completed_campaign.name

    # Hide failed campaigns
    expect(page).not_to have_content failed_campaign.name
  end
end
