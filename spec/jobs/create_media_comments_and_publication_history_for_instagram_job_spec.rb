require 'rails_helper'

RSpec.describe CreateMediaCommentsAndPublicationHistoryForInstagramJob, type: :job do
  let(:account) { create(:social_media_account, :instagram, username: 'ngomonginuang') }
  let(:brand) { create(:brand, name: 'Ngomongin uang', instagram: 'ngomonginuang') }
  let(:campaign) { create(:campaign, keyword: 'polisi, ai', hashtag: 'ai') }
  let(:media_plan) { create(:media_plan, campaign: campaign) }
  let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }

  it 'returns nothing and report to Sentry if SocialMediaPublication not found' do
    expect(Sentry).to receive(:capture_message).with("No publication found with id: 1 for platform: instagram")
    described_class.new(1).perform_now
  end

  it 'not to raise error when not found the IG' do
    # it should handles lamadava error exception instead
    # create or mock social media publication with invalid url manually (no need to be vcr, because it'll raise exception in the first place)
    expect {
      publication = create(:social_media_publication, :instagram, url: 'no-found', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)
      described_class.new.perform(publication.id)
    }.not_to raise_error ActiveInstagram::Drivers::MediaNotFoundError
  end

  it 'create media comments for ig when data was valid' do
    publication = create(:social_media_publication, :instagram, url: 'CwgBILCyaUy', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)

    expect(publication.media_comments.instagram.count).to be_zero
    expect(publication.media_comments.related_to_brand.count).to be_zero

    described_class.new.perform(publication.id)

    # Check the creation data for media comments
    publication.reload
    expect(publication.media_comments.tiktok.count).to be_zero
    # TODO: It should be more than 15, but it's not working because of the hikerapi bug
    expect(publication.media_comments.instagram.count).to eq(35)
    # TODO: It should be more than 1, but it's not working because of the hikerapi bug
    expect(publication.media_comments.related_to_brand.count).to eq(3)

    # Check the sample media comment record
    sample_data = publication.media_comments.last
    expect(sample_data.platform_id).to be_present
    expect(sample_data.comment_at).to be_present
    expect(sample_data.payload).to be_present
    expect(sample_data.content).to be_present

    # Check the recalculate metrics logic
    # TODO: It should be more than 35, but it's not working because of the hikerapi bug
    expect(publication.comments_count).to eq 35
    expect(publication.likes_count).to eq 157
    expect(publication.reach).to eq 1308
    expect(publication.impressions).to eq 1635
    expect(publication.share_count).to be_zero
    expect(publication.related_media_comments_count).to eq 3

    # Check the publication history creation
    publication_history = publication.publication_histories.first
    expect(publication_history).to have_attributes(
      comments_count: publication.media_comments_count,
      likes_count: publication.likes_count,
      reach: publication.reach,
      impressions: publication.impressions,
      engagement_rate: publication.engagement_rate,
      share_count: publication.share_count,
      campaign_id: publication.campaign_id,
      platform: publication.platform,
      social_media_account_size: publication.social_media_account.size,
      social_media_account_id: publication.social_media_account_id,
      related_media_comments_count: publication.related_media_comments_count
    )
  end

  it 'create expected media comments when job run two times' do
    publication = create(:social_media_publication, :instagram, url: 'CpM0xpJJqno', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)

    # Returns expected media comments at first runs
    described_class.new.perform(publication.id)
    media_comments = publication.media_comments.instagram
    expect(media_comments.size).to eq 56

    # Remove the publication history to allow system to delete comment
    publication_history = publication.publication_histories.first
    publication_history.destroy!

    # delete last media comments
    last_comment = media_comments.order(comment_at: :desc).first
    last_comment.destroy!

    # Returns expected media comments at second runs
    described_class.new.perform(publication.id)
    expect(media_comments.size).to eq 55
  end
end
