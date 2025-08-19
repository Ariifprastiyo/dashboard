require 'rails_helper'

RSpec.feature "PreCampaign::AddInfluencers", type: :feature, js: false do
  let(:user) { create(:admin) }
  let(:campaign) { create(:campaign, user: user) }

  before do
    sign_in user
    visit influencers_path
  end

  before(:all) do
    # make sure we pass the logic for taking the post max 3 months old
    Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
  end

  after(:all) do
    Timecop.return
  end

  scenario 'user adds a tiktok influencer to a campaign' do
    create_influencer

    click_on 'Add Social Media Account'

    select 'Tiktok', from: 'Platform'
    fill_in 'Username', with: 'keluargaburw'
    fill_in 'Story buying price', with: '100000'
    fill_in 'Story session buying price', with: '100000'
    fill_in 'Feed photo buying price', with: '100000'
    fill_in 'Feed video buying price', with: '100000'
    fill_in 'Reel buying price', with: '100000'
    fill_in 'Live buying price', with: '100000'
    fill_in 'Live buying price', with: '100000'

    click_on 'Buat Social media account'

    expect(page).to have_content('keluargaburw')
  end

  scenario 'user adds an instagram influencer to a campaign' do
    create_influencer

    click_on 'Add Social Media Account'

    select 'Instagram', from: 'Platform'
    fill_in 'Username', with: 'adhytia'
    fill_in 'Story buying price', with: '100000'
    fill_in 'Story session buying price', with: '100000'
    fill_in 'Feed photo buying price', with: '100000'
    fill_in 'Feed video buying price', with: '100000'
    fill_in 'Reel buying price', with: '100000'
    fill_in 'Live buying price', with: '100000'
    fill_in 'Live buying price', with: '100000'

    click_on 'Buat Social media account'

    expect(page).to have_content('adhytia')
  end

  def create_influencer
    click_on 'New Influencer'
    fill_in 'Name', with: 'Adhytia'
    select 'Female', from: 'Gender'
    fill_in 'Email', with: 'vina@mail.com'
    fill_in 'Phone number', with: '081234567890'
    fill_in 'Pic', with: 'Vina'
    fill_in 'Pic phone number', with: '081234567890'
    fill_in 'No ktp', with: '1234567890'
    fill_in 'No npwp', with: '1234567890'
    fill_in 'Address', with: 'Jl. Jago No. 1'
    click_on 'Buat Influencer'

    expect(page).to have_content('Adhytia')
    expect(page).to have_content('Vina')
    expect(page).to have_content('081234567890')
    expect(page).to have_content('female')
  end
end
