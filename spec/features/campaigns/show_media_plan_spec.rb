require 'rails_helper'

RSpec.describe 'Campaigns::ShowMediaPlan', type: :feature do
  before do
    super_admin = create(:super_admin)
    sign_in super_admin
  end

  it 'returns expected page' do
    media_plan = create(:media_plan)
    social_media_account = create(:social_media_account, :instagram)
    media_plan.social_media_accounts << social_media_account

    visit media_plan_path(media_plan)

    expect(page).to have_content media_plan.name
    expect(page).to have_content social_media_account.username
  end
end
