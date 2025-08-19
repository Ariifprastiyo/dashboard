require 'rails_helper'

RSpec.describe 'Managements::BulkSocialMediaAccountsImports', type: :feature do
  # make sure we pass the logic for taking the post max 3 months old
  Timecop.freeze(Time.parse("2023-03-10 14:02:08"))

  after(:all) do
    Timecop.return
  end

  let(:user) { create(:admin) }
  let(:management) { create(:management) }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'bulk_social_media_accounts_imports.csv') }

  before do
    sign_in user
  end

  it 'returns expected title page' do
    visit new_management_bulk_social_media_accounts_path(management)

    expect(page).to have_content 'Bulk Import Social Media Accounts'
  end

  it 'renders expected page when successfully import accounts' do
    create(:social_media_account, :instagram, username: 'fadiljaidi')
    trans7tiktok = create(:social_media_account, :tiktok, username: 'officialtrans7')
    management.social_media_accounts << trans7tiktok

    visit new_management_bulk_social_media_accounts_path(management)

    attach_file 'file', file_path
    click_on 'Simpan'

    success_message = 'Import completed: 1 accounts were successfully imported from 4 rows.'
    expect(page).to have_content success_message
    error_messages = [
      'No. 1 - instagram - raditya_dika not found',
      'No. 2 - tiktok - radityadika28 not found',
      'No. 3 - tiktok - officialtrans7 already exists'
    ]
    error_messages.each do |error_message|
      expect(page).to have_content error_message
    end
  end

  it 'only render errors when all imports data was invalid' do
    fadil_ig = create(:social_media_account, :instagram, username: 'fadiljaidi')
    trans7_tiktok = create(:social_media_account, :tiktok, username: 'officialtrans7')
    management.social_media_accounts << fadil_ig
    management.social_media_accounts << trans7_tiktok

    visit new_management_bulk_social_media_accounts_path(management)

    attach_file 'file', file_path
    click_on 'Simpan'

    success_message = 'Import completed: 0 accounts were successfully imported from 4 rows.'
    expect(page).not_to have_content success_message
    error_messages = [
      'No. 1 - instagram - raditya_dika not found',
      'No. 2 - tiktok - radityadika28 not found',
      'No. 3 - tiktok - officialtrans7 already exists',
      'No. 4 - instagram - fadiljaidi already exists'
    ]
    error_messages.each do |error_message|
      expect(page).to have_content error_message
    end
  end
end
