require 'rails_helper'

RSpec.feature "BulkInfluencers", type: :feature do
  let(:user) { create(:admin) }
  let(:fixture_path) { Rails.root.join('spec', 'fixtures', 'files', 'bulk_influencers.xlsx').to_s }

  before do
    sign_in user
  end

  scenario 'create a new bulk influencer' do
    visit new_bulk_influencer_path

    # Using direct file path
    attach_file('bulk_influencer_bulk_influencer_file', fixture_path, make_visible: true, visible: :all)

    click_button 'Buat Bulk influencer'
    expect(page).to have_content('We will upload your data in background job')
  end
end
