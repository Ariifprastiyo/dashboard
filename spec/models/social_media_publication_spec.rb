require 'rails_helper'

RSpec.describe SocialMediaPublication, type: :model do
  it { validate_presence_of(:url) }
  it { is_expected.to have_many(:publication_histories) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  after do
    ActiveJob::Base.queue_adapter.enqueued_jobs.clear
  end

  it 'creates social media publication with valid attributes' do
    social_media_publication = build(:social_media_publication, :instagram)
    expect(social_media_publication.save).to be_truthy
  end

  describe '#total_engagement' do
    it 'returns expected result' do
      publication = build(:social_media_publication, likes_count: 10, comments_count: 10, share_count: 10, saves_count: 10)
      expect(publication.total_engagement).to eq(40)
    end
  end

  describe '::new' do
    context 'when the platform is instagram' do
      xit 'formats the url' do
        social_media_publication = SocialMediaPublication.new(url: 'https://www.instagram.com/p/Cm6gLZrI21p/')
        expect(social_media_publication.url).to eq('Cm6gLZrI21p')
      end

      it 'accepts post id' do
        social_media_publication = SocialMediaPublication.new(url: 'Cm6gLZrI21p')

        expect(social_media_publication.url).to eq('Cm6gLZrI21p')
      end
    end

    context 'when the platform is tiktok' do
      xit 'accepts full url' do
        social_media_publication = SocialMediaPublication.new(url: 'https://www.tiktok.com/@keluargaburw/video/7157111344112700699?is_copy_url=1&is_from_webapp=v1&q=keluargaburw&t=1673335417594')
        expect(social_media_publication.url).to eq('7157111344112700699')
      end

      it 'accepts post id' do
        social_media_publication = SocialMediaPublication.new(url: '7157111344112700699')

        expect(social_media_publication.url).to eq('7157111344112700699')
      end
    end
  end

  describe 'after_create' do
    context 'when the platform is instagram' do
      # https://www.instagram.com/p/Cm6gLZrI21p/
      let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
      let(:campaign) { create(:campaign) }
      let(:media_plan) { create(:media_plan, campaign: campaign) }
      let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
      let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }
      let!(:social_media_publication) { create(:social_media_publication, :instagram, url: 'Cm6gLZrI21p', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }

      # these metrics are written as is without any calculation
      it 'populates likes_count, comments_count, impressions' do
        expect(social_media_publication.likes_count).to eq(656393)
        expect(social_media_publication.comments_count).to eq(6703)
        expect(social_media_publication.impressions).to eq(6370224)
      end

      it 'not enqueues job to create media comments for instagram' do
        expect(CreateMediaCommentsAndPublicationHistoryForTiktokJob).not_to have_been_enqueued.with(social_media_publication.id)
        expect(CreateMediaCommentsAndPublicationHistoryForInstagramJob).to have_been_enqueued.with(social_media_publication.id)
      end

      it 'populates publication date' do
        date = Time.zone.parse('2023-01-02 13:17:57.000000000 UTC')
        expect(social_media_publication.post_created_at).to eq(date)
      end

      it 'populates id' do
        expect(social_media_publication.post_identifier).to eq('3006857222193114473')
      end

      it 'populates reach' do
        expect(social_media_publication.reach).to eq(5096179)
      end

      it 'populates engagement_rate' do
        allow_any_instance_of(SocialMediaAccount).to receive(:followers).and_return(3_000_000)

        expect(social_media_publication.engagement_rate).to eq(10.409304288200854)
      end

      it 'populates caption' do
        expect(social_media_publication.caption).to eq('Anjay wkwkwkwkwkwkwwkk')
      end

      it 'populates payload' do
        payload = social_media_publication.payload

        expect(payload).to be_a(Hash)
        expect(payload['shortcode']).to eq('Cm6gLZrI21p')
      end

      it 'atttach the thumbnail' do
        expect(social_media_publication.thumbnail).to be_attached
      end

      it 'assign social_media_account_id' do
        account = SocialMediaAccount.find_by(platform_user_identifier: 846852257)

        expect(social_media_publication.social_media_account_id).to eq(account.id)
      end

      context 'when the post is already exist' do
        it 'does not create new post' do
          expect { create(:social_media_publication, :instagram, url: 'Cm6gLZrI21p') }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end

      context 'when the post is not exist' do
        it 'not to raises error and update deleted by third party flag' do
          publication = nil
          expect {
              publication = create(:social_media_publication, :instagram, social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item, url: 'xxxxxxxxxxxx')
            }.not_to raise_error(ActiveInstagram::Drivers::MediaNotFoundError)
          expect(publication).to be_persisted
          expect(publication.deleted_by_third_party).to be_truthy
        end
      end

      xit 'categorize as video' do
        expect(social_media_publication.video?).to be_truthy
      end

      xit 'categorize as image' do
        image = create(:social_media_publication, :instagram, url: 'CmoYjJer_Nc', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)

        expect(image.video?).to be_falsey
      end

      xit 'categorize as carousel' do
        carousel = create(:social_media_publication, :instagram, url: 'Cl5hdGzrd-N/', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)

        expect(carousel.carousel?).to be_truthy
      end
    end

    context 'when the platform is tiktok' do
      before(:all) do
        # make sure we pass the logic for taking the post max 3 months old
        Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
      end

      after(:all) do
        Timecop.return
      end

      # https://www.tiktok.com/@fadiljaidi/video/7171787903637458202
      let(:post_id) { '7171787903637458202' }
      let(:account) { create(:social_media_account, :tiktok, username: 'fadiljaidi') }
      let(:campaign) { create(:campaign) }
      let(:media_plan) { create(:media_plan, campaign: campaign) }
      let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
      let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }
      let(:social_media_publication) { create(:social_media_publication, :tiktok, url: post_id, social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }

      # these metrics are written as is without any calculation
      it 'populates likes_count, comments_count, impressions' do
        expect(social_media_publication.likes_count).to eq(1_733_560)
        expect(social_media_publication.comments_count).to eq(6_290)
        expect(social_media_publication.impressions).to eq(17527131)
        expect(social_media_publication.reach).to eq(17527131)
        expect(social_media_publication.share_count).to eq(9315)
      end

      it 'enqueues job to create media comments for tiktok' do
        expect(CreateMediaCommentsAndPublicationHistoryForTiktokJob).to have_been_enqueued.with(social_media_publication.id)
      end

      it 'populates post identifier' do
        expect(social_media_publication.post_identifier).to eq(post_id)
      end

      it 'populates post date' do
        expect(social_media_publication.post_created_at).to eq(Time.zone.parse('2022-11-30 19:39:57.000000000 +0700'))
      end

      it 'populates caption' do
        expect(social_media_publication.caption).to eq('Di curangin balik WKWKWKWKWKWKWK')
      end

      it 'populates engagement_rate' do
        expect(social_media_publication.engagement_rate).to eq(9.979722968046273)
      end

      it 'populates payload' do
        expect(social_media_publication.payload).to be_a(Hash)
      end

      it 'assign social_media_account_id' do
        expect(social_media_publication.social_media_account_id).to eq(account.id)
      end

      xit 'categorize as video' do
        expect(social_media_publication.video?).to be_truthy
      end

      xit 'creates publication history' do
        # includes in CreateMediaCommentsForTikTok and Instagram
        expect(social_media_publication.publication_histories.count).to eq(1)
      end

      it 'attach thumbnail' do
        expect(social_media_publication.thumbnail.attached?).to be_truthy
      end
    end
  end

  describe '#update_scope_of_work_item_posted_at' do
    context 'when the platform is instagram' do
      let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
      let(:campaign) { create(:campaign) }
      let(:media_plan) { create(:media_plan, campaign: campaign) }
      let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
      let!(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000, posted_at: nil) }
      let!(:social_media_publication) { create(:social_media_publication, :instagram, url: 'Cm6gLZrI21p', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }
      let!(:publication_history) { create(:publication_history, campaign: campaign, social_media_publication: social_media_publication, social_media_account: account, platform: :instagram, reach: 100, likes_count: 100, share_count: 100, comments_count: 100, engagement_rate: 100, created_at: '2023-01-01', social_media_account_size: :mega) }

      it 'updates the posted_at attribute of the associated scope_of_work_item after create' do
        expect(scope_of_work_item.posted_at).to eq(social_media_publication.post_created_at)
      end
    end
  end

  describe '#fetch_and_populate_tiktok_post_data' do
    before(:all) do
      # make sure we pass the logic for taking the post max 3 months old
      Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
    end

    after(:all) do
      Timecop.return
    end

    let(:post_id) { '7171787903637458202' }
    let(:account) { create(:social_media_account, :tiktok, username: 'fadiljaidi') }
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
    let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }

    # TODO : Need to analyze the response from the API based on this https://tikapi.io/documentation/#section/Errors
    it 'update flag deleted by third party' do
      publication = create(:social_media_publication, :tiktok, manual: true, url: '7372168058397314312', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item)
      expect(publication).not_to be_deleted_by_third_party
      publication.update(url: post_id + '1234')
      publication.fetch_and_populate_tiktok_post_data
      publication.reload
      expect(publication).to be_deleted_by_third_party
    end
  end

  describe '.need_sync_daily_update' do
    let(:campaign) { create(:campaign) }
    let(:account) { create(:social_media_account, :instagram, username: 'ngomonginuang') }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
    let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }

    it 'returns only when the campaign is active' do
      campaign = create(:campaign, :active,
        start_at: 1.day.ago,
        end_at: 1.day.from_now
      )
      publication1 = create(:social_media_publication, :instagram, url: 'CoXBwY6pXNM',   social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item)
      publication1.update(last_sync_at: 2.day.ago)

      campaign2 = create(:campaign, :completed,
        start_at: 1.day.ago,
        end_at: 1.day.from_now
      )
      publication2 = create(:social_media_publication, :instagram, url: 'Cpha7AeJlIh',   social_media_account: account, campaign: campaign2, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item)
      publication2.update(last_sync_at: 2.day.ago)

      campaign3 = create(:campaign, :draft,
        start_at: 1.day.ago,
        end_at: 1.day.from_now
      )
      publication3 = create(:social_media_publication, :instagram, url: 'Cp2A9jZprv-',   social_media_account: account, campaign: campaign3, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item)
      publication3.update(last_sync_at: 2.day.ago)

      # Debug each condition separately
      manual_check = described_class.where(manual: false)
      expect(manual_check).to include(publication1)

      active_check = described_class.joins(:campaign).where(campaigns: { status: :active })
      expect(active_check).to include(publication1)

      deleted_check = described_class.where(deleted_by_third_party: false)
      expect(deleted_check).to include(publication1)

      period_check = described_class.joins(:campaign)
        .where('campaigns.start_at <= ?', Time.current)
        .where('campaigns.end_at >= ?', Time.current)
      expect(period_check).to include(publication1)

      # Final check with all conditions
      need_daily_sync = described_class.need_sync_daily_update
      expect(need_daily_sync.ids).to eq [publication1.id]
    end

    it 'dont return when its already deleted by third party' do
      campaign = create(:campaign, :active)
      publication1 = create(:social_media_publication, :instagram, url: 'CoXBwY6pXNM',   social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item)
      publication1.update(last_sync_at: 2.day.ago, deleted_by_third_party: true)
      need_daily_sync = described_class.need_sync_daily_update
      expect(need_daily_sync).to be_blank
    end

    it 'returns only publications within campaign period' do
      current_time = Time.current
      active_campaign = create(:campaign, :active,
        start_at: current_time - 1.day,
        end_at: current_time + 1.day
      )
      future_campaign = create(:campaign, :active,
        start_at: current_time + 1.day,
        end_at: current_time + 2.days
      )
      past_campaign = create(:campaign, :active,
        start_at: current_time - 2.days,
        end_at: current_time - 1.day
      )

      active_publication = create(:social_media_publication, :instagram,
        url: 'CoXBwY6pXNM',
        social_media_account: account,
        campaign: active_campaign,
        scope_of_work: scope_of_work,
        scope_of_work_item: scope_of_work_item
      )
      future_publication = create(:social_media_publication, :instagram,
        url: 'Cpha7AeJlIh',
        social_media_account: account,
        campaign: future_campaign,
        scope_of_work: scope_of_work,
        scope_of_work_item: scope_of_work_item
      )
      past_publication = create(:social_media_publication, :instagram,
        url: 'Cp2A9jZprv-',
        social_media_account: account,
        campaign: past_campaign,
        scope_of_work: scope_of_work,
        scope_of_work_item: scope_of_work_item
      )

      [active_publication, future_publication, past_publication].each do |pub|
        pub.update(last_sync_at: 2.days.ago)
      end

      need_daily_sync = described_class.need_sync_daily_update
      expect(need_daily_sync.ids).to eq [active_publication.id]
    end
  end

  describe 'sync_daily_update' do
    before(:all) do
      # make sure we pass the logic for taking the post max 3 months old
      Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
    end

    after(:all) do
      Timecop.return
    end

    let(:account) { create(:social_media_account, :tiktok, username: 'fadiljaidi') }
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
    let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }
    let!(:social_media_publication) { create(:social_media_publication, social_media_account: account, platform: :tiktok, url: '7256966771289296133', campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }

    before do
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
      social_media_publication.update(likes_count: 0, last_sync_at: 5.day.ago, impressions: 0, reach: 0, engagement_rate: 0)
    end

    it 'updates likes_count' do
      expect { social_media_publication.sync_daily_update }.to change { social_media_publication.likes_count }.from(0).to(22)
    end

    it 'enqueue job for create media comments when publication for tiktok' do
      social_media_publication.sync_daily_update
      expect(CreateMediaCommentsAndPublicationHistoryForTiktokJob).to have_been_enqueued.with(social_media_publication.id)
    end

    it 'updates comments_count' do
      expect { social_media_publication.sync_daily_update }.not_to change { social_media_publication.comments_count }
    end

    it 'updates impressions' do
      expect { social_media_publication.sync_daily_update }.to change { social_media_publication.impressions }.from(0).to(201)
    end

    it 'updates reach' do
      expect { social_media_publication.sync_daily_update }.to change { social_media_publication.reach }.from(0).to(201)
    end

    it 'updates engagement_rate' do
      expect { social_media_publication.sync_daily_update }.to change { social_media_publication.engagement_rate }.from(0).to(10.945273631840797)
    end

    it 'updates share_count' do
    end

    it 'updates last_sync_at' do
      time = DateTime.new(2020, 1, 2, 3)
      Timecop.freeze(time) do
        last_sync_at = 2.days.ago.beginning_of_day
        social_media_publication.last_sync_at = last_sync_at

        expect { social_media_publication.sync_daily_update }.to change { social_media_publication.last_sync_at }.from(last_sync_at).to(time)
      end
    end

    it 'updates last_error_during_sync' do
      # assume the error is 404
      social_media_publication.update(last_error_during_sync: '404')

      expect { social_media_publication.sync_daily_update }.to change { social_media_publication.last_error_during_sync }.from('404').to(nil)
    end

    it 'skips if last_sync_at is today' do
      time = DateTime.new(2020, 1, 2, 3)
      Timecop.freeze(time) do
        social_media_publication.update(last_sync_at: time)

        expect { social_media_publication.sync_daily_update }.not_to change { social_media_publication.last_sync_at }
        expect { social_media_publication.sync_daily_update }.not_to change { social_media_publication.likes_count }
      end
    end

    it 'skips if its manual publication' do
      social_media_publication.manual = true

      expect { social_media_publication.sync_daily_update }.not_to change { social_media_publication.last_sync_at }
      expect { social_media_publication.sync_daily_update }.not_to change { social_media_publication.likes_count }
    end

    it 'recalculates campaigns metrics likes_count' do
      expect { social_media_publication.sync_daily_update }.to change { campaign.likes_count }.from(0).to(22)
    end

    it 'recalculates campaigns metrics comments_count' do
      expect { social_media_publication.sync_daily_update }.not_to change { campaign.comments_count }
    end

    it 'recalculates campaigns metrics impressions' do
      expect { social_media_publication.sync_daily_update }.to change { campaign.impressions }.from(0).to(201)
    end

    it 'enqueue job for create media comments when publication for instagram' do
      account = create(:social_media_account, :instagram, username: 'ngomonginuang')
      publication = create(:social_media_publication, :instagram, url: 'CoXBwY6pXNM',   social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item)
      publication.update(last_sync_at: 5.days.ago)
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      publication.sync_daily_update

      expect(CreateMediaCommentsAndPublicationHistoryForTiktokJob).not_to have_been_enqueued.with(publication.id)
      expect(CreateMediaCommentsAndPublicationHistoryForInstagramJob).to have_been_enqueued.with(publication.id)
    end
  end

  describe '#recalculate_the_last_publication_history_metrics' do
    let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
    let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }
    let!(:social_media_publication) { create(:social_media_publication, :instagram, url: 'Cm6gLZrI21p', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }
    let!(:publication_history) { create(:publication_history, social_media_publication: social_media_publication, likes_count: 1, comments_count: 2, impressions: 3, reach: 4, engagement_rate: 5) }

    it 'recalculates the last publication history metrics' do
      social_media_publication.recalculate_the_last_publication_history_metrics

      publication_history = social_media_publication.publication_histories.last

      expect(publication_history.likes_count).to eq(social_media_publication.likes_count)
      expect(publication_history.comments_count).to eq(social_media_publication.comments_count)
      expect(publication_history.impressions).to eq(social_media_publication.impressions)
      expect(publication_history.reach).to eq(social_media_publication.reach)
      expect(publication_history.engagement_rate).to eq(social_media_publication.engagement_rate)
    end
  end

  describe '#crb' do
    context 'when media_comments_count is zero' do
      it 'returns 0' do
        publication = build(:social_media_publication, media_comments_count: 0, related_media_comments_count: 10)
        expect(publication.crb).to eq(0)
      end
    end

    context 'when media_comments_count is not zero' do
      it 'calculates the crb' do
        publication = build(:social_media_publication, media_comments_count: 20, related_media_comments_count: 5)
        expect(publication.crb).to eq(25.0)
      end
    end
  end

  describe 'costs cpv, cpr and cpe' do
    let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
    let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }

    describe '#cpv' do
      let(:social_media_publication) { build(:social_media_publication, :instagram, url: 'Cm6gLZrI21p', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }
      it 'returns 0 if view is 0' do
        allow(social_media_publication).to receive(:impressions).and_return(0)

        expect(social_media_publication.cpv).to eq(0)
      end

      it 'returns 0 if sell_price from sow_item is nil' do
        allow(social_media_publication).to receive(:impressions).and_return(1000)
        allow(social_media_publication.scope_of_work_item).to receive(:sell_price).and_return(nil)

        expect(social_media_publication.cpv).to eq(0)
      end

      it 'returns the cpv' do
        allow(social_media_publication).to receive(:impressions).and_return(1000)

        expect(social_media_publication.cpv).to eq(1)
      end
    end

    describe '#cpr' do
      let(:social_media_publication) { build(:social_media_publication, :instagram, url: 'Cm6gLZrI21p', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }
      it 'returns 0 if reach is 0' do
        allow(social_media_publication).to receive(:reach).and_return(0)

        expect(social_media_publication.cpr).to eq(0)
      end

      it 'returns 0 if sell_price from sow_item is nil' do
        allow(social_media_publication).to receive(:reach).and_return(1000)
        allow(social_media_publication.scope_of_work_item).to receive(:sell_price).and_return(nil)

        expect(social_media_publication.cpr).to eq(0)
      end

      it 'returns the cpr' do
        allow(social_media_publication).to receive(:reach).and_return(500)

        expect(social_media_publication.cpr).to eq(2)
      end
    end

    describe '#cpe' do
      let(:social_media_publication) { build(:social_media_publication, :instagram, url: 'Cm6gLZrI21p', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }
      it 'returns 0 if total_engagement is 0' do
        allow(social_media_publication).to receive(:total_engagement).and_return(0)

        expect(social_media_publication.cpe).to eq(0)
      end

      it 'returns 0 if sell_price from sow_item is nil' do
        allow(social_media_publication).to receive(:total_engagement).and_return(1000)
        allow(social_media_publication.scope_of_work_item).to receive(:sell_price).and_return(nil)

        expect(social_media_publication.cpe).to eq(0)
      end

      it 'returns the cpe' do
        allow(social_media_publication).to receive(:total_engagement).and_return(200)

        expect(social_media_publication.cpe).to eq(5)
      end
    end
  end
end
