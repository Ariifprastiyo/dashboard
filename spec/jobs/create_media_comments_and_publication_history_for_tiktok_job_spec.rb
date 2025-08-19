require 'rails_helper'

RSpec.describe CreateMediaCommentsAndPublicationHistoryForTiktokJob, type: :job do
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

  it 'returns nil when the publication is not found' do
    job = described_class.new.perform(0)
    expect(job).to be_blank
  end

  it 'creates media reply comments for tiktok post', vcr: { allow_playback_repeats: true } do
    publication = create(:social_media_publication, :tiktok, url: '6880418257325542657', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)

    perform_enqueued_jobs do
      described_class.new.perform(publication.id)
    end

    publication.reload
    expect(publication.media_comments_count).to eq 48

    all_comments = publication.media_comments.tiktok.pluck(:content)

    # Test the comments parents
    parent_comments = [
      'gimana caranya bertani jika gak ada lahan',
      'sukses selalu petani Indonesia.dimotori anak muda hebat dan energik.'
    ]
    parent_comments.each do |comment|
      expect(all_comments).to include comment
    end

    # TODO: Pending active_tiktok development
    # Test the replied comments
    # replied_comments = [
    #   'budikdamber mungkin solusinya om',
    #   'yang cocok agar tanamanan cepat tumbuh berbuah,dll.',
    #   'hidroponik di depan rmh atau belakang rumh, sedikit demi sedikit bisa berkembang'
    # ]
    # replied_comments.each do |comment|
    #   expect(all_comments).to include comment
    # end
  end

  it 'creates media comments for tiktok post', vcr: { allow_playback_repeats: true } do
    publication = create(:social_media_publication, :tiktok, url: '7198829003472375066', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)

    perform_enqueued_jobs do
      described_class.new.perform(publication.id)
    end

    publication.reload

    # Check the creation data for media comments
    expect(publication.media_comments.instagram.size).to be_zero
    expect(publication.media_comments.tiktok.size).to eq 53
    expect(publication.media_comments.related_to_brand.size).to eq 1

    # Check the media comment record
    sample_data = publication.media_comments.tiktok.first
    expect(sample_data.platform_id).to be_present
    expect(sample_data.comment_at).to be_present
    expect(sample_data.payload).to be_present

    # Check the recalculate metrics logic
    expect(publication.comments_count).to eq 94
    expect(publication.likes_count).to eq 12012
    expect(publication.reach).to eq 304688
    expect(publication.impressions).to eq 304688
    expect(publication.share_count).to eq 483
    expect(publication.related_media_comments_count).to eq 1

    # Check the publication history creation
    publication_history = publication.publication_histories.first
    expect(publication_history).to have_attributes(
      comments_count: 94,
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

  it 'create expected media comments when job running twice' do
    account = create(:social_media_account, :tiktok, username: 'capcapungofficial', manual: true)
    scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: account)
    publication = create(:social_media_publication, :tiktok, url: '7142021167803632922', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)

    perform_enqueued_jobs do
      described_class.new.perform(publication.id)
    end

    media_comments = publication.media_comments.tiktok
    expect(media_comments.size).to eq 38

    # Remove the publication history to allow system to delete comment
    publication_history = publication.publication_histories.first
    publication_history.destroy!

    # delete last media comments
    last_comment = media_comments.order(comment_at: :desc).first
    last_comment.destroy!

    # Run the job again
    perform_enqueued_jobs do
      described_class.new.perform(publication.id)
    end

    media_comments.reload
    expect(media_comments.size).to eq 38
  end
end
