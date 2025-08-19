require 'rails_helper'

RSpec.describe SocialMediaAccount, type: :model do
  it { should have_many(:payment_requests) }

  before(:all) do
    # make sure we pass the logic for taking the post max 3 months old
    Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
  end

  after(:all) do
    Timecop.return
  end

  describe 'after_create' do
    context 'when platform is instagram' do
      it 'should populate platform_user_identifier' do
        social_media_account = create_instagram_account

        expect(social_media_account.platform_user_identifier).to eq(4964040851.to_s)
      end

      it 'should populate followers' do
        social_media_account = create_instagram_account

        expect(social_media_account.followers).to eq(6299)
      end

      it 'should attach profile_picture' do
        social_media_account = create_instagram_account

        expect(social_media_account.profile_picture.attached?).to eq(true)
      end

      it 'should populate estimated_impression' do
        social_media_account = create_instagram_account

        expect(social_media_account.estimated_impression).to eq(2661)
      end

      it 'should populate estimated_reach' do
        social_media_account = create_instagram_account

        expect(social_media_account.estimated_reach).to eq(2519)
      end

      it 'should populate estimated comments count' do
        social_media_account = create_instagram_account

        expect(social_media_account.estimated_comments_count).to eq(1)
      end

      it 'should populate estimated likes count' do
        social_media_account = create_instagram_account

        expect(social_media_account.estimated_likes_count).to eq(19)
      end

      it 'should populate estimated share count' do
        # DataLama doesn't provide this data
        social_media_account = create_instagram_account

        expect(social_media_account.estimated_share_count).to be_nil
      end

      it 'should populate estimated_engagement_rate' do
        social_media_account = create_instagram_account

        expect(social_media_account.estimated_engagement_rate).to eq(1.7265355098007589)
      end

      it 'should populate estimated_engagement_rate_branding_post' do
        social_media_account = create_instagram_account

        expect(social_media_account.estimated_engagement_rate_branding_post).to eq(1.0)
      end

      it 'should populate estimated_engagement_rate_average' do
        # based on average of estimated_engagement_rate and estimated_engagement_rate_branding_post
        social_media_account = create_instagram_account
        avg = (social_media_account.estimated_engagement_rate + social_media_account.estimated_engagement_rate_branding_post) / 2

        expect(social_media_account.estimated_engagement_rate_average).to eq(avg)
      end

      it 'raise error when ActiveInstagram.user_by_username returns not found' do
        expect { create(:social_media_account, :instagram, username: 'aditoro99999', estimated_impression: 0, estimated_reach: 0, estimated_engagement_rate: 0, estimated_engagement_rate_branding_post: 0) }.to raise_error(ActiveInstagram::Drivers::ProfileNotFoundError)
      end

      it 'should calculate only max 3 months posts' do
        time = Time.parse("2024-01-22 11:01:27")
        Timecop.freeze(time + 3.months) do
          social_media_account = create_instagram_account
          expect(social_media_account.last_sync_at).to eq(time + 3.months)
          expect(social_media_account.estimated_engagement_rate).to eq(1.9959155129117452)
        end
      end
    end

    context 'when platform is tiktok' do
      let(:active_tiktok_user_result) do
        {
          id: "MS4wLjABAAAAJu9GE5G8FHvrndADLPQq1PiJyIpuWMLiuB_kgbdfE_3j6hfW1jC4-aoYJAHp0GMl",
          username: "kucingdirumahburw",
          full_name: "kucing dirumah bu RW",
          followed_by_count: 0,
          bio: "This is a bio",
          website: "https://somewebsite.com",
          profile_picture: nil,
          follows_count: 21,
          media_count: 4
        }
      end

      let(:active_tiktok_medias_result) do
        []
      end

      let(:tiktok_metrics) do
        {
          estimated_impression: 10,
          estimated_engagement_rate: 1,
          estimated_reach: 8,
          estimated_likes_count: 88,
          estimated_comments_count: 99,
          estimated_share_count: 77
        }
      end

      let(:active_tiktok_user) { instance_double(ActiveTiktok::Models::User, active_tiktok_user_result) }
      let(:active_tiktok_medias) { instance_double(ActiveTiktok::Models::MediasCollection) }
      let(:tiktok_metrics_calculator) { instance_double(TiktokMetricsCalculatorService, tiktok_metrics) }

      before do
        allow(ActiveTiktok).to receive(:user_by_username).with('kucingdirumahburw').and_return(active_tiktok_user)
        allow(ActiveTiktok).to receive(:medias_by_user_id).and_return(active_tiktok_medias)
        allow(TiktokMetricsCalculatorService).to receive(:new).and_return(tiktok_metrics_calculator)
      end

      let(:social_media_account) { create(:social_media_account, :tiktok, username: 'kucingdirumahburw', estimated_engagement_rate_branding_post: 5) }

      it 'should populate platform_user_identifier' do
        expect(social_media_account.platform_user_identifier).to eq(active_tiktok_user_result[:id])
      end

      it 'should populate followers' do
        expect(social_media_account.followers).to eq(active_tiktok_user_result[:followed_by_count])
      end

      it 'should attach profile_picture' do
        expect(social_media_account.profile_picture.attached?).to eq(false)
      end

      it 'should populate estimated_impression' do
        expect(social_media_account.estimated_impression).to eq(tiktok_metrics[:estimated_impression])
      end

      it 'should populate estimated_reach' do
        expect(social_media_account.estimated_reach).to eq(tiktok_metrics[:estimated_reach])
      end

      it 'should populate estimated_engagement_rate' do
        expect(social_media_account.estimated_engagement_rate).to eq(tiktok_metrics[:estimated_engagement_rate])
      end

      it 'should populate estimated_engagement_rate_branding_post' do
        expect(social_media_account.estimated_engagement_rate_branding_post).to eq(5)
      end

      it 'should populate estimated_engagement_rate_average' do
        avg = (tiktok_metrics[:estimated_engagement_rate] + 5) / 2

        expect(social_media_account.estimated_engagement_rate_average).to eq(avg)
      end

      it 'should populate estimated comments count' do
        expect(social_media_account.estimated_comments_count).to eq(tiktok_metrics[:estimated_comments_count])
      end

      it 'should populate estimated likes count' do
        expect(social_media_account.estimated_likes_count).to eq(tiktok_metrics[:estimated_likes_count])
      end

      it 'should populate estimated share count' do
        expect(social_media_account.estimated_share_count).to eq(tiktok_metrics[:estimated_share_count])
      end

      # TODO: will fix it later
      # it 'should not populate anything if tiktok service return nil' do
      #   time = Time.zone.now
      #   Timecop.freeze(time)

      #   tikapi_profile_service = double('tikapi_profile_service', :failed? => true)
      #   allow(TikapiProfileService).to receive(:new).and_return(tikapi_profile_service)
      #   allow(tikapi_profile_service).to receive(:call).and_return(false)
      #   allow(tikapi_profile_service).to receive(:failed?).and_return(true)

      #   social_media_account = create(:social_media_account, :tiktok)

      #   expect(social_media_account.platform_user_identifier).to eq(nil)
      #   expect(social_media_account.last_sync_at).not_to eq(time)
      # end

      it 'should update last_synced_at' do
        time = Time.zone.now.change(nsec: 0)
        Timecop.freeze(time) do
          sleep 2

          expect(social_media_account.last_sync_at).to eq(time)
        end
      end
    end
  end

  describe 'before_save set_size' do
    before do
      @social_media_account = create(:social_media_account, :instagram_mega_manual)
    end

    it 'should assign influencer size to nano' do
      @social_media_account.update(followers: 1000)

      expect(@social_media_account.size).to eq('nano')
    end

    it 'should assign influencer size to micro' do
      @social_media_account.update(followers: 10_000)

      expect(@social_media_account.size).to eq('micro')
    end

    it 'should assign influencer size to macro' do
      @social_media_account.update(followers: 100_000)

      expect(@social_media_account.size).to eq('macro')
    end

    it 'should assign influencer size to mega' do
      @social_media_account.update(followers: 1_000_000)

      expect(@social_media_account.size).to eq('mega')
    end
  end

  describe 'costs related' do
    let(:social_media_account) { build(:social_media_account,
      story_price: 1000,
      feed_photo_price: 2000,
      feed_video_price: 3000,
      estimated_impression: 10_000) }

    describe '#cost' do
      it 'pick the highest value between prices' do
        expect(social_media_account.cost).to eq(3000)
      end
    end

    describe '#cpv' do
      it 'returns 0 if estimated_impression is 0' do
        social_media_account.estimated_impression = 0

        expect(social_media_account.cpv).to eq(0)
      end

      it 'returns 0 if cost is 0' do
        allow(social_media_account).to receive(:cost).and_return(0)

        expect(social_media_account.cpv).to eq(0)
      end

      it 'should calculate cost per view' do
        cpv = social_media_account.cost / social_media_account.estimated_impression

        expect(social_media_account.cpv).to eq(cpv)
      end
    end

    describe '#cpe' do
      it 'returns 0 if estimated_total_engagement is 0' do
        allow(social_media_account).to receive(:estimated_total_engagement).and_return(0)

        expect(social_media_account.cpe).to eq(0)
      end

      it 'returns 0 if cost is 0' do
        allow(social_media_account).to receive(:cost).and_return(0)

        expect(social_media_account.cpe).to eq(0)
      end

      it 'should calculate cost per engagement' do
        allow(social_media_account).to receive(:estimated_total_engagement).and_return(100)

        cpe = social_media_account.cost / social_media_account.estimated_total_engagement

        expect(social_media_account.cpe).to eq(cpe)
      end
    end

    describe '#cpr' do
      it 'returns 0 if estimated_reach is 0' do
        social_media_account.estimated_reach = 0

        expect(social_media_account.cpr).to eq(0)
      end

      it 'returns 0 if cost is 0' do
        allow(social_media_account).to receive(:cost).and_return(0)

        expect(social_media_account.cpr).to eq(0)
      end

      it 'should calculate cost per reach' do
        cpr = social_media_account.cost / social_media_account.estimated_reach

        expect(social_media_account.cpr).to eq(cpr)
      end
    end
  end

  describe '#gross_estimated_reach' do
    let(:social_media_account) { build(:social_media_account,
        story_price: 1000,
        feed_photo_price: 2000,
        feed_video_price: 3000,
        estimated_impression: 10_000) }

    it 'returns 40% of the followers' do
      allow(social_media_account).to receive(:followers).and_return(1000)
      expected_reach = 400

      expect(social_media_account.gross_estimated_reach).to eq(expected_reach)
    end

    it 'returns 0 if followers are blank' do
      allow(social_media_account).to receive(:followers).and_return(nil)

      expect(social_media_account.gross_estimated_reach).to eq(0)
    end
  end
end

def create_instagram_account
  influencer = create(:influencer)
  social_media_account = create(:social_media_account, influencer: influencer, platform: 'instagram', username: 'rollerskool', estimated_engagement_rate_branding_post: 1)
  social_media_account
end
