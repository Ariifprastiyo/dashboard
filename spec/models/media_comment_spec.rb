require 'rails_helper'

RSpec.describe MediaComment, type: :model do
  let(:post_id) { '7171787903637458202' }
  let(:account) { create(:social_media_account, :tiktok, username: 'fadiljaidi') }
  let(:campaign) { create(:campaign, keyword: 'keyword1, keyword2', hashtag: 'hashtag') }
  let(:media_plan) { create(:media_plan, campaign: campaign) }
  let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }

  before(:all) do
    ActiveJob::Base.queue_adapter = :test
    # make sure we pass the logic for taking the post max 3 months old
    Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
  end

  after(:all) do
    Timecop.return
  end

  describe '#crb_keywords' do
    it 'returns expected things' do
      publication = create(:social_media_publication, :tiktok, url: post_id, social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)
      comment = create(:media_comment, social_media_publication: publication, content: 'This is a comment with keyword1 and keyword2 and Brand Name and #hashtag')
      expect(comment.crb_keywords).to eq(%w[keyword1 keyword2 brand_tiktok hashtag])
    end
  end

  it 'updates crb like expected' do
    publication = create(:social_media_publication, :tiktok, url: post_id, social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)
    first_history = create(:publication_history, social_media_publication: publication, comments_count: 0, related_media_comments_count: 0)
    last_history = create(:publication_history, social_media_publication: publication, comments_count: 1, related_media_comments_count: 1)

    comment = create(:media_comment, social_media_publication: publication, content: 'This is a comment with keyword1 and keyword2 and Brand Name and #hashtag')
    expect(comment).to be_related_to_brand
    publication.reload
    expect(publication.related_media_comments_count).to eq(1)
    campaign.reload
    expect(campaign.related_media_comments_count).to eq(1)

    # Updates to unrelated
    perform_enqueued_jobs do
      comment.manually_update_related_to_brand(false)
    end
    publication.reload
    expect(publication.related_media_comments_count).to be_zero
    campaign.reload
    expect(campaign.related_media_comments_count).to be_zero
    last_history.reload
    expect(last_history.comments_count).to eq 1
    expect(last_history.related_media_comments_count).to be_zero

    # Updates to related again
    perform_enqueued_jobs do
      comment.manually_update_related_to_brand(true)
    end

    publication.reload
    expect(publication.related_media_comments_count).to eq 1
    campaign.reload
    expect(campaign.related_media_comments_count).to eq 1
    last_history.reload
    expect(last_history.comments_count).to eq 1
    expect(last_history.related_media_comments_count).to eq 1
    first_history.reload
    expect(first_history.comments_count).to be_zero
    expect(first_history.related_media_comments_count).to be_zero
  end

  it 'sets related_to_brand to true if comment contains any of the crb keywords' do
    publication = create(:social_media_publication, :tiktok, url: post_id, social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)
    comment = create(:media_comment, social_media_publication: publication, content: 'This is a comment with keyword1 and keyword2 and Brand Name and #hashtag')
    expect(comment).to be_related_to_brand
  end

  it 'sets related_to_brand to false if comment contains any of the crb keywords' do
    publication = create(:social_media_publication, :tiktok, url: post_id, social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)
    comment = create(:media_comment, social_media_publication: publication, content: 'Hello world')
    expect(comment).not_to be_related_to_brand
  end
end
