require 'rails_helper'

RSpec.describe 'Campaigns::ListingSocialMediaAccounts', type: :feature do
  before do
    admin = create(:admin)
    sign_in admin
  end

  it 'returns expected page' do
    account = create(:social_media_account, :instagram)
    visit social_media_accounts_path

    expect(page).to have_content 'Social Media Accounts'
    expect(page).to have_content account.username
  end
end
