require 'rails_helper'

RSpec.feature 'SowInvitations::SubmitInvitation', type: :feature do
  let(:account) { create(:social_media_account, :instagram, username: 'ngomonginuang') }
  let(:account_2) { create(:social_media_account, :instagram, :instagram_micro_manual) }
  let(:account_3) { create(:social_media_account, :instagram, :instagram_mega_manual) }
  let(:account_4) { create(:social_media_account, :instagram, :instagram_mega_manual) }
  let(:management) { create(:management_with_accounts, social_media_accounts: [account_2, account_3, account_4]) }
  let(:brand) { create(:brand, name: 'Ngomongin uang', instagram: 'ngomonginuang') }
  let(:campaign) { create(:campaign, keyword: 'uang, ai', hashtag: 'ai', invitation_expired_at: 1.month.from_now) }
  let(:media_plan) { create(:media_plan, campaign: campaign) }
  let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
  let(:scope_of_work_2) { create(:scope_of_work, media_plan: media_plan, social_media_account: account_2, management: management) }
  let(:scope_of_work_3) { create(:scope_of_work, media_plan: media_plan, social_media_account: account_3, management: management) }
  let(:scope_of_work_4) { create(:scope_of_work, media_plan: media_plan, social_media_account: account_4, management: management) }

  before do
    admin = create(:admin)
    sign_in admin
  end

  context 'influencer' do
    it 'returns expected without npwp field input' do
      visit sow_invitation_path(scope_of_work.uuid)

      # Expect welcome page
      welcome_text = 'Kamu diundang untuk menjadi influencer!'
      expect(page).to have_content(welcome_text)

      # Expect personal data input
      expect(page).to have_content 'Data ini akan digunakan untuk proses pembayaran'

      fill_in 'social_media_account_influencer_attributes_no_ktp', with: '198273123'
      select 'Tidak memiliki NPWP', from: 'social_media_account_influencer_attributes_have_npwp'
      fill_in 'social_media_account_influencer_attributes_no_npwp', with: ''
      fill_in 'social_media_account_influencer_attributes_address', with: 'Jalan'
      fill_in 'social_media_account_influencer_attributes_account_number', with: '123123123'
      click_on 'Submit'

      # Expect success response
      expect(page).to have_content 'Terima Kasih!'
      expect(page).to have_content 'Tim dari kami akan segera menghubungi anda.'
    end

    it 'returns expected with npwp field input' do
      visit sow_invitation_path(scope_of_work.uuid)

      # Expect welcome page
      welcome_text = 'Kamu diundang untuk menjadi influencer!'
      expect(page).to have_content(welcome_text)

      # Expect personal data input
      expect(page).to have_content 'Data ini akan digunakan untuk proses pembayaran'

      fill_in 'social_media_account_influencer_attributes_no_ktp', with: '198273123'
      select 'Sudah memiliki NPWP', from: 'social_media_account_influencer_attributes_have_npwp'
      fill_in 'social_media_account_influencer_attributes_no_npwp', with: '9812039123'
      fill_in 'social_media_account_influencer_attributes_address', with: 'Jalan'
      fill_in 'social_media_account_influencer_attributes_account_number', with: '123123123'
      click_on 'Submit'

      # Expect success response
      expect(page).to have_content 'Terima Kasih!'
      expect(page).to have_content 'Tim dari kami akan segera menghubungi anda.'
    end

    it 'returns expected updated price' do
      visit sow_invitation_path(scope_of_work.uuid)

      fill_in 'social_media_account_story_price', with: '1000000'
      fill_in 'social_media_account_live_price', with: '500000'

      fill_in 'social_media_account_influencer_attributes_no_ktp', with: '198273123'
      select 'Sudah memiliki NPWP', from: 'social_media_account_influencer_attributes_have_npwp'
      fill_in 'social_media_account_influencer_attributes_no_npwp', with: '9812039123'
      fill_in 'social_media_account_influencer_attributes_address', with: 'Jalan'
      fill_in 'social_media_account_influencer_attributes_account_number', with: '123123123'
      click_on 'Submit'

      expect(scope_of_work.scope_of_work_items.where(name: 'story')[0].price).to eq(1000000)
      expect(scope_of_work.scope_of_work_items.where(name: 'live')[0].price).to eq(500000)
    end
  end

  context 'management' do
    it 'returns expected title' do
      visit sow_invitation_path(scope_of_work_2.uuid)

      # Expect welcome page
      title_text = "Hi, #{management.name}"
      welcome_text = "Kamu diundang untuk menjadi influencer!"
      expect(page).to have_content(title_text)
      expect(page).to have_content(welcome_text)
    end

    it 'returns expected sizes' do
      scope_of_work
      scope_of_work_2
      scope_of_work_3
      scope_of_work_4

      visit sow_invitation_path(scope_of_work_2.uuid)

      # Expect sizes text
      expect(page).to have_content("Micro")
      expect(page).to have_content("Mega")
      expect(page).not_to have_content("Nano")
      expect(page).not_to have_content("Macro")
    end

    it 'returns expected prices' do
      scope_of_work
      scope_of_work_2
      scope_of_work_3
      scope_of_work_4

      visit sow_invitation_path(scope_of_work_2.uuid)

      expect(page).to have_content("Story")
      expect(page).to have_content("Live")
      expect(page).not_to have_content("Reel")
    end

    it 'returns success page' do
      scope_of_work
      scope_of_work_2
      scope_of_work_3
      scope_of_work_4

      visit sow_invitation_path(scope_of_work_2.uuid)

      # fill price
      fill_in 'social_media_account_micro_story', with: '100000'
      fill_in 'social_media_account_mega_live', with: '200000'

      # Expect personal data input
      expect(page).to have_content 'Data ini akan digunakan untuk proses pembayaran'

      fill_in 'social_media_account_influencer_attributes_no_ktp', with: '198273123'
      select 'Sudah memiliki NPWP', from: 'social_media_account_influencer_attributes_have_npwp'
      fill_in 'social_media_account_influencer_attributes_no_npwp', with: '9812039123'
      fill_in 'social_media_account_influencer_attributes_address', with: 'Jalan'
      fill_in 'social_media_account_influencer_attributes_account_number', with: '123123123'
      click_on 'Submit'

      # Expect success response
      expect(page).to have_content 'Terima Kasih!'
      expect(page).to have_content 'Tim dari kami akan segera menghubungi anda.'

      expect(scope_of_work_2.scope_of_work_items.where(name: 'story')[0].price).to eq(100000)
      expect(scope_of_work_3.scope_of_work_items.where(name: 'live')[0].price).to eq(200000)
      expect(scope_of_work_4.scope_of_work_items.where(name: 'live')[0].price).to eq(200000)
    end
  end
end
