require 'rails_helper'

RSpec.feature "ImportSocialMediaPublications", type: :feature do
  let(:user) { create(:user) }
  let(:brand) { create(:brand) }
  let(:campaign) { create(:campaign, brand: brand) }

  # fadijaidi and adhytia are included in the fixture file
  let!(:fadiljaidi) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
  let!(:adhytia) { create(:social_media_account, :instagram, username: 'adhytia') }
  let(:file_path) { Rails.root.join('spec', 'fixtures', 'files', 'bulk_publication_template.xlsx') }

  before do
    ActiveJob::Base.queue_adapter = :test

    user.add_role(:super_admin)
    sign_in user
  end

  scenario "User imports a bulk publication" do
    visit new_campaign_import_social_media_publication_path(campaign)

    attach_file('bulk_publication_bulk_publication_file', file_path)
    click_button 'Buat Bulk publication'

    expect(page).to have_content('We will upload your data in background job')
    expect(BulkPublication.count).to eq(1)
    expect(BulkPublication.last.bulk_publication_file).to be_attached
    expect(BulkPublication.last.campaign).to eq(campaign)
    expect(BulkPublication.last.job_id).to be_present
    expect(BulkPublicationJob).to have_been_enqueued.with(BulkPublication.last.id, campaign.id)
  end
end
