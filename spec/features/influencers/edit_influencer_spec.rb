require 'rails_helper'

RSpec.feature 'Influencers::EditInfluencer', type: :feature do
  before do
    admin = create(:admin)
    sign_in admin
  end

  it 'returns expected response when successful edit without NPWP' do
    influencer = create(:influencer)
    visit edit_influencer_path(influencer)
    fill_in 'influencer_name', with: 'Influencer 1'
    select 'Male', from: 'influencer_gender'
    select 'Tidak memiliki NPWP', from: 'influencer_have_npwp'
    fill_in 'influencer_no_npwp', with: ''
    click_on 'Perbarui Influencer'
    expect(page).to have_content 'Influencer was successfully updated.'
  end

  it 'returns expected response when successful edit with NPWP' do
    influencer = create(:influencer)
    visit edit_influencer_path(influencer)
    fill_in 'influencer_name', with: 'Influencer 1'
    select 'Male', from: 'influencer_gender'
    select 'Sudah memiliki NPWP', from: 'influencer_have_npwp'
    fill_in 'influencer_no_npwp', with: '0981023123'
    click_on 'Perbarui Influencer'
    expect(page).to have_content 'Influencer was successfully updated.'
  end
end
