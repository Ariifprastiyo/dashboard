require 'rails_helper'

RSpec.feature "PreCampaign::AddBrand", type: :feature, js: false do
  let(:user) { create(:super_admin) }
  let(:campaign) { create(:campaign, user: user) }

  before do
    sign_in user
    visit brands_path
  end

  before(:all) do
    Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
  end

  after(:all) do
    Timecop.return
  end

  scenario 'user adds a brand to a campaign' do
    click_on 'New Brand'

    fill_in 'Name', with: 'Brand'
    attach_file 'Logo', Rails.root.join('spec/fixtures/images/logo.png')
    fill_in 'Description', with: 'Brand Description'
    fill_in 'Instagram', with: 'brand'
    fill_in 'Tiktok', with: 'brand'

    click_on 'Buat Brand'

    expect(page).to have_content('Brand was successfully created.')
    expect(page).to have_content('Brand')
    expect(page).to have_content('Campaigns')
    expect(page).to have_content('Past Campaigns')
  end
end
