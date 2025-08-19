require 'rails_helper'

RSpec.describe 'Campaigns::ListingMediaComments' do
  let(:post_id) { '7171787903637458202' }
  let(:account) { create(:social_media_account, :tiktok, username: 'fadiljaidi') }
  let(:campaign) { create(:campaign, keyword: 'keyword1, keyword2', hashtag: 'hashtag') }
  let(:media_plan) { create(:media_plan, campaign: campaign) }
  let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
  let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }

  before do
    admin = create(:admin)
    admin.add_role(:super_admin)
    sign_in admin
  end

  before(:all) do
    # make sure we pass the logic for taking the post max 3 months old
    Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
  end

  after(:all) do
    Timecop.return
  end

  it 'returns list of media comments' do
    publication = create(:social_media_publication, :tiktok, url: post_id, social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item)
    create(:publication_history, social_media_publication: publication, comments_count: 0, related_media_comments_count: 0)
    create(:publication_history, social_media_publication: publication, comments_count: 1, related_media_comments_count: 1)

    comment = create(:media_comment, social_media_publication: publication, content: 'This is a comment with keyword1 and keyword2 and Brand Name and #hashtag')

    visit media_comments_path(campaign)

    # Expect returns expeted title
    expect(page).to have_content('Comment Related to Brand review')

    # Expect returns expected columns
    columns = [
      'No',
      'Comment',
      'Date',
      'Status',
      'Manual Reviewed',
      'Action'
    ]
    columns.each do |column|
      expect(page).to have_content column
    end

    # Expect the relate & relate button works as expected
    within "#media_comment_#{comment.id}" do
      within '.status' do
        expect(page).to have_content 'related'
      end

      click_on 'unrelate'

      within '.status' do
        expect(page).to have_content 'unrelated'
      end

      click_on 'relate'

      within '.status' do
        expect(page).to have_content 'relate'
      end
    end
  end
end
