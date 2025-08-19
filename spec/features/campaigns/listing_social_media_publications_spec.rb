require 'rails_helper'

RSpec.feature 'Campaings::ListingSocialMediaPublications', type: :feature do
  # make sure we pass the logic for taking the post max 3 months old
  Timecop.freeze(Time.parse("2023-03-10 14:02:08"))

  after(:all) do
    Timecop.return
  end

  let(:account) { create(:social_media_account, :tiktok, username: 'capcapungofficial') }
  let(:brand) { create(:brand, name: 'Capcapung', tiktok: 'capcapungofficial') }
  let(:campaign) { create(:campaign, keyword: 'petani, ikan, bertani', hashtag: 'petani_indonesia') }
  let(:media_plan) { create(:media_plan, campaign: campaign) }
  let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
  let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }

  before do
    admin = create(:super_admin)
    sign_in admin
  end

  it 'returns expected list of social media publications' do
    publication = create(:social_media_publication, :tiktok, url: '6880418257325542657', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item)

    visit campaigns_social_media_publications_path(campaign)

    # Expect expected title
    expect(page).to have_content "Social Media Publications for #{campaign.name}"

    # Expect expected table columns
    columns = [
      '#',
      'Account Username',
      'Account Size',
      'URL',
      'Media Comments Count',
      'Related Media Comments Count',
      'Likes Count',
      'Share Count',
      'Engagement Rate',
      'CRB',
      'Created At'
    ]
    columns.each do |column|
      expect(page).to have_content column
    end

    # Expect expected social media publication data
    publication_row = [
      publication.social_media_account_username,
      publication.social_media_account_size,
      publication.post_identifier,
      publication.media_comments_count,
      publication.related_media_comments_count,
      publication.likes_count,
      publication.share_count,
      '4,55%',
      '0%',
      publication.created_at_in_formatted
    ]
    publication_row.each do |row|
      expect(page).to have_content row
    end
  end
end
