require 'rails_helper'

RSpec.describe ScopeOfWork, type: :model do
  # it should accepts big number as total
  it 'should accept big number as total' do
    media_plan = create(:media_plan, scope_of_work_template: { live: 1 })
    social_media_account = create(:social_media_account, :instagram, live_price: 1000000000000)
    scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account, total: 1000000000000)

    expect(scope_of_work.total).to eq(1000000000000)
  end

  # validation make sure only 1 sow per account per media plan
  it 'should not add the same social media account twice' do
    media_plan = create(:media_plan)
    social_media_account = create(:social_media_account, :instagram)
    create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)

    expect { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }.to raise_error(ActiveRecord::RecordInvalid, 'Validasi gagal: Social media account has already been added')
  end

  describe 'after_create' do
    it 'creates default scope of work items using scope of work template' do
      media_plan = create(:media_plan, scope_of_work_template: { 'live' => 1, 'story' => 2, 'feed_video' => 0 })
      social_media_account = create(:social_media_account, :instagram, live_price: '100', story_price: '200')
      create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)

      expect(media_plan.scope_of_works.first.scope_of_work_items.count).to eq(3)
      expect(media_plan.scope_of_works.first.scope_of_work_items.first.name).to eq('live')
      expect(media_plan.scope_of_works.first.scope_of_work_items.second.name).to eq('story')
      expect(media_plan.scope_of_works.first.scope_of_work_items.first.price).to eq(100)
      expect(media_plan.scope_of_works.first.scope_of_work_items.second.price).to eq(200)
    end

    describe '#update_social_media_account_stats' do
      let(:media_plan) { create(:media_plan, scope_of_work_template: { 'live' => 1, 'story' => 2, 'feed_video' => 0 }) }
      let(:social_media_account) { create(:social_media_account, :instagram, live_price: '100', story_price: '200') }
      let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }

      it 'enqueues SingleSocialMediaAccountUpdaterJob' do
        expect {
          scope_of_work.send(:update_social_media_account_stats)
        }.to have_enqueued_job(SingleSocialMediaAccountUpdaterJob)
          .with(social_media_account.id, media_plan.id)
          .on_queue("default")
          .exactly(2).times
      end
    end
  end

  describe 'recalculate_metrics' do
    let!(:campaign) { create(:campaign) }
    let!(:account) { create(:social_media_account, :tiktok, username: 'fadiljaidi') }
    let!(:media_plan) { create(:media_plan, campaign: campaign) }
    let!(:scope_of_work) { create(:scope_of_work, social_media_account: account, media_plan: media_plan) }

    before(:all) do
      # make sure we pass the logic for taking the post max 3 months old
      Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
    end

    after(:all) do
      Timecop.return
    end

    it 'calculates total comments count' do
      expect { create_publication }.to change { scope_of_work.reload.comments_count }.from(0).to(6290)
    end

    it 'calculates total likes count' do
      expect { create_publication }.to change { scope_of_work.reload.likes_count }.from(0).to(1733564)
    end

    it 'calculates total share count' do
      expect { create_publication }.to change { scope_of_work.reload.share_count }.from(0).to(9316)
    end

    it 'calculates total impressions' do
      expect { create_publication }.to change { scope_of_work.reload.impressions }.from(0).to(17527242)
    end

    it 'calculates total reach' do
      expect { create_publication }.to change { scope_of_work.reload.reach }.from(0).to(17527242)
    end

    it 'calculates total engagement rate' do
      expect { create_publication }.to change { scope_of_work.reload.engagement_rate }.from(0.0).to 9.97972185241694
    end

    it 'calculates total engagement rate' do
      create_publication

      expect(scope_of_work.reload.total_engagement).to eq(1749170)
    end

    def create_publication
      create(:social_media_publication, :tiktok, url: '7171787903637458202', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)
    end
  end

  describe '#view_rate' do
    let!(:campaign) { create(:campaign) }
    let!(:account) { create(:social_media_account, :tiktok, username: 'fadiljaidi') }
    let!(:media_plan) { create(:media_plan, campaign: campaign) }
    let!(:scope_of_work) { create(:scope_of_work, social_media_account: account, media_plan: media_plan) }

    it 'calculates view rate' do
      view_rate = scope_of_work.impressions / account.followers.to_f

      expect(scope_of_work.view_rate).to eq(view_rate)
    end
  end
end
