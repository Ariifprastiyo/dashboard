require 'rails_helper'

RSpec.describe Campaign, type: :model do
  # campaign validation specs
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:start_at) }
  it { should validate_presence_of(:end_at) }
  it { should validate_presence_of(:status) }
  it { should validate_presence_of(:kpi_engagement_rate) }
  it { should validate_presence_of(:kpi_impression) }
  it { should validate_presence_of(:kpi_reach) }
  it { should validate_presence_of(:budget) }
  it { should validate_presence_of(:kpi_cpr) }
  it { should validate_presence_of(:kpi_cpv) }
  it { should validate_numericality_of(:kpi_engagement_rate) }
  it { should validate_numericality_of(:kpi_impression) }
  it { should validate_numericality_of(:kpi_reach) }
  it { should validate_numericality_of(:budget) }
  it { should validate_numericality_of(:kpi_cpr) }
  it { should validate_numericality_of(:kpi_cpv) }
  it { should validate_numericality_of(:kpi_crb) }

  # campaign association specs
  it { should belong_to(:brand) }
  it { should have_many(:media_plans) }

  # campaign enum specs
  it { should define_enum_for(:status).with_values(draft: 0, active: 1, completed: 2, failed: 3) }

  describe 'ransack' do
    it 'returns a list of searchable attributes' do
      attributes = Campaign.ransackable_attributes

      expect(attributes).to be_an(Array)
      expect(attributes).to include("brand_id", "budget", "budget_from_brand", "client_sign_name", "comments_count", "created_at", "description", "discarded_at", "end_at", "engagement_rate", "hashtag", "id", "id_value", "impressions", "invitation_expired_at", "keyword", "kpi_cpe", "kpi_cpr", "kpi_cpv", "kpi_crb", "kpi_engagement_rate", "kpi_impression", "kpi_number_of_social_media_accounts", "kpi_reach", "likes_count", "management_fees", "media_comments_count", "mediarumu_pic_name", "mediarumu_pic_phone", "name", "notes_and_media_terms", "payment_terms", "platform", "reach", "related_media_comments_count", "selected_media_plan_id", "share_count", "show_rate_price_comment", "show_rate_price_feed_photo", "show_rate_price_feed_video", "show_rate_price_host", "show_rate_price_link_in_bio", "show_rate_price_live", "show_rate_price_live_attendance", "show_rate_price_other", "show_rate_price_owning_asset", "show_rate_price_photoshoot", "show_rate_price_reel", "show_rate_price_story", "show_rate_price_story_session", "show_rate_price_tap_link", "start_at", "status", "updated_at", "updated_target_plan_for_reach")
    end

    it 'can retrieve a list of ransackable associations' do
      associations = Campaign.ransackable_associations
      expected_associations = ["brand", "bulk_publications", "media_plans", "publication_histories", "selected_media_plan", "social_media_publications"]
      expect(associations).to eq(expected_associations)
    end
  end

  describe '#comment_related_to_brand_percentage' do
    context 'when media_comments_count is 0' do
      it 'returns 0' do
        campaign = build(:campaign, media_comments_count: 0)

        expect(campaign.comment_related_to_brand_percentage).to eq(0)
      end
    end

    context 'when media_comments_count is not 0' do
      it 'calculates the percentage of related media comments' do
        campaign = build(:campaign, media_comments_count: 10, related_media_comments_count: 5)

        expect(campaign.comment_related_to_brand_percentage).to eq(50.0)
      end
    end
  end

  before(:all) do
    # make sure we pass the logic for taking the post max 3 months old
    Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
  end

  after(:all) do
    Timecop.return
  end

  it 'recalculate crb metrics after hastag or keyword changed' do
    post_id = '7171787903637458202'
    account = create(:social_media_account, :tiktok, username: 'fadiljaidi')
    campaign = create(:campaign, keyword: 'one', hashtag: 'somethingelse')
    media_plan = create(:media_plan, campaign: campaign)
    scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: account)
    publication = create(:social_media_publication, :tiktok, url: post_id, social_media_account: account, campaign: campaign, scope_of_work: scope_of_work)
    create(:media_comment, social_media_publication: publication, content: 'One')
    create(:media_comment, social_media_publication: publication, content: 'Two')
    create(:media_comment, social_media_publication: publication, content: 'Three')
    create(:media_comment, social_media_publication: publication, content: 'Four #hashtag')
    comment = create(:media_comment, social_media_publication: publication, content: 'satu dua tiga')

    campaign.social_media_publications << publication

    # Manual update to related
    perform_enqueued_jobs do
      comment.manually_update_related_to_brand(true)
    end
    campaign.reload

    expect(campaign.related_media_comments_count).to eq 2

    # Updates the keyword
    perform_enqueued_jobs do
      campaign.keyword = 'one, two'
      campaign.save
    end
    campaign.reload

    expect(campaign.related_media_comments_count).to eq 3


    # Updates the keyword and hashtag
    perform_enqueued_jobs do
      campaign.update!(hashtag: 'hashtag')
    end
    campaign.reload
    expect(campaign.media_comments_count).to eq 5
    expect(campaign.related_media_comments_count).to eq 4
  end

  describe '#updated_target_plan_for_reach_in' do
    it 'returns nil when updated_target_plan_for_reach is blank' do
      campaign = build(:campaign, updated_target_plan_for_reach: nil)
      updated_plan = campaign.updated_target_plan_for_reach_in('2020-01-01')
      expect(updated_plan).to be_blank
    end

    it 'returns expected updated target plan' do
      target_plan = { '2020-01-01' => 100, '2020-01-02' => 200 }
      campaign = build(:campaign, updated_target_plan_for_reach: target_plan)
      updated_plan = campaign.updated_target_plan_for_reach_in('2020-01-01')
      expect(updated_plan).to eq 100
    end

    it 'returns blank when date was not found' do
      target_plan = { '2020-01-01' => 100, '2020-01-02' => 200 }
      campaign = build(:campaign, updated_target_plan_for_reach: target_plan)
      updated_plan = campaign.updated_target_plan_for_reach_in('2020-01-03')
      expect(updated_plan).to be_blank
    end
  end

  describe 'recalculate_metrics' do
    let(:campaign) { create(:campaign) }
    let(:account) { create(:social_media_account, :tiktok, username: 'fadiljaidi') }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, social_media_account: account, media_plan: media_plan) }
    let!(:social_media_publication) { create(:social_media_publication, :tiktok, url: '7171787903637458202', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work) }
    let!(:social_media_publication_2) { create(:social_media_publication, :tiktok, url: '7087219936258444571', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work) }

    it 'calculates total comments count' do
      total_comments_count = social_media_publication.comments_count + social_media_publication_2.comments_count

      expect(campaign.comments_count).to eq(total_comments_count)
    end

    it 'calculates total likes count' do
      total_likes_count = social_media_publication.likes_count + social_media_publication_2.likes_count

      expect(campaign.likes_count).to eq(total_likes_count)
    end

    it 'calculates total share count' do
      total_share_count = social_media_publication.share_count + social_media_publication_2.share_count

      expect(campaign.share_count).to eq(total_share_count)
    end

    it 'calculates total impressions' do
      impressions = social_media_publication.impressions + social_media_publication_2.impressions

      expect(campaign.impressions).to eq(impressions)
    end

    it 'calculates total reach' do
      reach = social_media_publication.reach + social_media_publication_2.reach

      expect(campaign.reach).to eq(reach)
    end

    it 'calculates total engagement rate' do
      expect(campaign.engagement_rate).to eq(10.531303257271205)
    end
  end

  describe 'budget_spent' do
    let(:campaign) { create(:campaign, budget: 15_000, budget_from_brand: 20_000) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:social_media_account) { create(:social_media_account, :instagram) }
    let(:social_media_account2) { create(:social_media_account, :instagram, username: 'adhytia') }
    let(:scope_of_work) { create(:scope_of_work, social_media_account: social_media_account,
                                  media_plan: media_plan,
                                  budget_spent: 1000, budget_spent_sell_price: 2000) }
    let(:scope_of_work2) { create(:scope_of_work, social_media_account: social_media_account2,
                                  media_plan: media_plan,
                                  budget_spent: 2000, budget_spent_sell_price: 5000) }
    before do
      media_plan.scope_of_works << scope_of_work
      media_plan.scope_of_works << scope_of_work2
      media_plan.save
    end

    context 'when campaign has selected media plan' do
      before do
        campaign.update(selected_media_plan: media_plan)
      end

      it 'returns total budget spent' do
        expect(campaign.budget_spent).to eq(3000)
      end

      it 'returns total budget spent sell price' do
        expect(campaign.budget_spent_sell_price).to eq(7000)
      end

      it 'returns budget remaining' do
        expect(campaign.budget_remaining).to eq(12_000)
      end
    end

    context 'when campaign has no selected media plan' do
      it 'returns total budget spent' do
        expect(campaign.budget_spent).to eq(0)
      end

      it 'returns total budget spent sell price' do
        expect(campaign.budget_spent_sell_price).to eq(0)
      end

      it 'returns budget remaining' do
        expect(campaign.budget_remaining).to eq(0)
      end
    end
  end

  describe 'cpv' do
    let(:campaign) { create(:campaign) }

    it 'returns 0 when impressions is 0' do
      allow(campaign).to receive(:impressions).and_return(0)

      expect(campaign.cpv).to eq(0)
    end

    it 'calculates posted sell_price divide by total campaign view ' do
      allow(campaign).to receive(:impressions).and_return(10)
      allow(campaign).to receive(:budget_spent_sell_price).and_return(100)

      expect(campaign.cpv).to eq(10)
    end
  end

  describe 'cpr' do
    let(:campaign) { create(:campaign) }

    it 'returns 0 when reach is 0' do
      allow(campaign).to receive(:reach).and_return(0)

      expect(campaign.cpr).to eq(0)
    end

    it 'calculates posted sell_price divide by total campaign reach ' do
      allow(campaign).to receive(:reach).and_return(10)
      allow(campaign).to receive(:budget_spent_sell_price).and_return(100)

      expect(campaign.cpr).to eq(10)
    end
  end

  describe 'cpe' do
    let(:campaign) { create(:campaign) }

    it 'returns 0 when engagement is 0' do
      allow(campaign).to receive(:likes_count).and_return(0)
      allow(campaign).to receive(:comments_count).and_return(0)
      allow(campaign).to receive(:share_count).and_return(0)

      expect(campaign.cpe).to eq(0)
    end

    it 'calculates posted sell_price divide by total campaign engagement ' do
      allow(campaign).to receive(:likes_count).and_return(10)
      allow(campaign).to receive(:comments_count).and_return(10)
      allow(campaign).to receive(:share_count).and_return(10)
      allow(campaign).to receive(:budget_spent_sell_price).and_return(900)

      expect(campaign.cpe).to eq(30)
    end
  end

  describe '#crb' do
    context 'when media_comments_count is 0' do
      it 'returns 0' do
        campaign = build(:campaign, media_comments_count: 0)

        expect(campaign.crb).to eq(0)
      end
    end

    context 'when media_comments_count is not 0' do
      it 'calculates the percentage of related media comments' do
        campaign = build(:campaign, media_comments_count: 10, related_media_comments_count: 5)

        expect(campaign.crb).to eq(50.0)
      end
    end
  end

  describe '#budget_remaining_sell_price' do
    context 'when selected_media_plan is nil' do
      it 'returns 0' do
        campaign = build(:campaign, selected_media_plan: nil)

        expect(campaign.budget_remaining_sell_price).to eq(0)
      end
    end

    context 'when selected_media_plan is not nil' do
      it 'calculates the remaining budget' do
        campaign = build(:campaign, budget_from_brand: 20000)
        media_plan = create(:media_plan)
        campaign.selected_media_plan = media_plan

        allow(campaign).to receive(:budget_spent_sell_price).and_return(5000)

        expect(campaign.budget_remaining_sell_price).to eq(15000)
      end
    end
  end

  describe '#er_progress' do
    it 'returns 0 when kpi_engagement_rate is 0' do
      campaign = build(:campaign, kpi_engagement_rate: 0)

      expect(campaign.er_progress).to eq(0)
    end

    it 'calculates the progress of engagement rate' do
      campaign = build(:campaign, kpi_engagement_rate: 10, engagement_rate: 5)

      expect(campaign.er_progress).to eq(50.0)
    end
  end

  describe '#kpi_crb_progress' do
    it 'returns 0 when kpi_crb is 0' do
      campaign = build(:campaign, kpi_crb: 0)

      expect(campaign.kpi_crb_progress).to eq(0)
    end

    it 'returns 0 if crb is 0' do
      campaign = build(:campaign, kpi_crb: 10, related_media_comments_count: 0)

      expect(campaign.kpi_crb_progress).to eq(0)
    end

    it 'calculates the progress of crb' do
      campaign = build(:campaign, kpi_crb: 50, related_media_comments_count: 5, media_comments_count: 10)

      expect(campaign.kpi_crb_progress).to eq(100.0)
    end
  end

  describe '#reach_progress' do
    it 'returns 0 when kpi_reach is 0' do
      campaign = build(:campaign, kpi_reach: 0)

      expect(campaign.reach_progress).to eq(0)
    end

    it 'returns 0 if reach is 0' do
      campaign = build(:campaign, kpi_reach: 10, reach: 0)

      expect(campaign.reach_progress).to eq(0)
    end

    it 'calculates the progress of reach' do
      campaign = build(:campaign, kpi_reach: 100, reach: 50)

      expect(campaign.reach_progress).to eq(50.0)
    end
  end

  describe '#impressions_progress' do
    it 'returns 0 when kpi_reach is 0' do
      campaign = build(:campaign, kpi_impression: 0)

      expect(campaign.impressions_progress).to eq(0)
    end

    it 'returns 0 if impressions is 0' do
      campaign = build(:campaign, kpi_impression: 10, impressions: 0)

      expect(campaign.impressions_progress).to eq(0)
    end

    it 'calculates the progress of impressions' do
      campaign = build(:campaign, kpi_impression: 100, impressions: 50)

      expect(campaign.impressions_progress).to eq(50.0)
    end
  end

  describe '#sync_all_publications' do
    let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
    let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }
    let!(:social_media_publication) { create(:social_media_publication, :instagram, url: 'Cm6gLZrI21p', social_media_account: account, campaign: campaign, scope_of_work: scope_of_work, scope_of_work_item: scope_of_work_item) }

    it 'syncs all publications' do
      campaign.social_media_publications << social_media_publication
      campaign.save

      expect(SingleSocialMediaPublicationUpdaterJob).to receive(:perform_later).with(social_media_publication.id).once

      campaign.sync_all_publications
    end
  end
end
