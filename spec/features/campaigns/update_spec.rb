require 'rails_helper'

RSpec.describe 'Campaigns::Update', type: :feature do
  before do
    super_admin = create(:super_admin)
    sign_in super_admin
  end

  it 'returns success response' do
    campaign = create(:campaign)
    visit edit_campaign_path(campaign)
    fill_in :campaign_name, with: 'New Campaign Name'
    # fill_in :campaign_hashtag, with: 'New Hashtag'
    # fill_in :campaign_keyword, with: 'New Keyword'
    click_on 'Perbarui Campaign'
    expect(page).to have_content 'Campaign was successfully updated.'
    expect(page).to have_content 'New Campaign Name'
  end
end
