require 'rails_helper'

RSpec.describe MediaPlan, type: :model do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it { should validate_presence_of(:name) }

  # relationships
  it { should belong_to(:campaign) }
  it { should have_many(:scope_of_works) }
  it { should have_many(:social_media_accounts) }

  it 'should not add the same social media account twice' do
    media_plan = create(:media_plan)
    social_media_account = create(:social_media_account, :instagram)
    media_plan.social_media_accounts << social_media_account

    expect { media_plan.social_media_accounts << social_media_account }.to raise_error(MediaPlan::MediaPlanError, 'social_media_account_id has already been added')
  end

  it { is_expected.to validate_presence_of(:scope_of_work_template) }

  it 'should not accept invalid scope of work template' do
    media_plan = build(:media_plan, scope_of_work_template: { 'invalid_key' => 1 })

    expect(media_plan).to_not be_valid
    expect(media_plan.errors[:scope_of_work_template]).to include('invalid key invalid_key')
  end

  it 'should accept valid scope of work template' do
    scope_of_work_template = ScopeOfWorkItem::PRICES.index_with { |price| 1 }

    media_plan = build(:media_plan, scope_of_work_template: scope_of_work_template)

    expect(media_plan).to be_valid
  end

  describe 'destroy' do
    it 'can not be destroyed if it the main mediaplan for the campaign' do
      campaign = create(:campaign)
      media_plan = create(:media_plan, campaign: campaign)

      campaign.update(selected_media_plan: media_plan)

      expect { media_plan.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end

  describe 'bulk_markup_sell_price' do
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }

    context "run bulk markup sell price job" do
      before do
        campaign
        media_plan
      end

      it 'should not run bulk markup sell price job' do
        social_media_account_sizes = { "mega": "1", "nano": "1", "micro": "1", "macro": "0" }
        sell_price_percentages = { 'live' => 10, 'story' => 20 }
        media_plan.bulk_markup_sell_price(social_media_account_sizes, sell_price_percentages)

        expect(BulkMarkupSellPriceJob).not_to have_been_enqueued.with(hash_including(sell_price_percentages: sell_price_percentages))
      end

      it 'should run bulk markup sell price job' do
        ActiveJob::Base.queue_adapter = :test
        tasyakamila = create(:influencer, name: 'Tasya Kamila')
        fadiljaidi = create(:influencer, name: 'Fadil Jaidi')
        social_media_account_mega_1 = create(:social_media_account, :instagram, username: 'fadiljaidi', live_price: '100', story_price: '200', influencer: fadiljaidi)
        social_media_account_mega_2 = create(:social_media_account, :instagram, username: 'tasyakamila',  influencer: tasyakamila)
        social_media_account_nano_1 = create(:social_media_account, :instagram, username: 'adhytia', live_price: '100', story_price: '150')
        social_media_account_micro_1 = create(:social_media_account, :instagram, username: 'adittoro', live_price: '300', story_price: '400')

        create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account_mega_1)
        create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account_mega_2)
        create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account_nano_1)
        sow_micro_1 = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account_micro_1)

        social_media_account_sizes = { "mega": "1", "nano": "1", "micro": "1", "macro": "0" }
        sell_price_percentages = { 'live' => 10, 'story' => 20 }
        media_plan.bulk_markup_sell_price(social_media_account_sizes, sell_price_percentages)

        expect(BulkMarkupSellPriceJob).to have_been_enqueued.with(scope_of_work_id: sow_micro_1.id, sell_price_percentages: sell_price_percentages)
      end
    end
  end

  describe 'costs related' do
    let(:media_plan) { create(:media_plan) }
    let(:social_media_account) { create(:social_media_account, :instagram, manual: true) }
    let(:social_media_account_2) { create(:social_media_account, :instagram, username: 'oke', manual: true) }

    describe '#total_sell_price' do
      it 'returns 0 if there is no scope of work' do
        expect(media_plan.total_sell_price).to eq(0)
      end

      it 'should return total sell price' do
        sow1 = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account)
        # update the total_sell_price by force
        sow1.update(total_sell_price: 100)

        sow2 = create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account_2)
        sow2.update(total_sell_price: 200)

        media_plan.reload

        expect(media_plan.total_sell_price).to eq(300)
      end
    end

    describe '#cpv' do
      it 'returns 0 if there is no scope of work' do
        expect(media_plan.cpv).to eq(0)
      end

      it 'returns 0 if total sell price is 0' do
        allow(media_plan).to receive(:total_sell_price).and_return(0)

        expect(media_plan.cpv).to eq(0)
      end

      it 'returns 0 if estimated impression is 0' do
        allow(media_plan).to receive(:estimated_impression).and_return(0)

        expect(media_plan.cpv).to eq(0)
      end

      it 'returns cpv' do
        allow(media_plan).to receive(:total_sell_price).and_return(1000)
        allow(media_plan).to receive(:estimated_impression).and_return(200)

        expect(media_plan.cpv).to eq(5)
      end
    end

    describe '#cpr' do
      it 'returns 0 if there is no scope of work' do
        expect(media_plan.cpr).to eq(0)
      end

      it 'returns 0 if total sell price is 0' do
        allow(media_plan).to receive(:total_sell_price).and_return(0)

        expect(media_plan.cpr).to eq(0)
      end

      it 'returns 0 if estimated reach is 0' do
        allow(media_plan).to receive(:estimated_reach).and_return(0)

        expect(media_plan.cpr).to eq(0)
      end

      it 'returns cpr' do
        allow(media_plan).to receive(:total_sell_price).and_return(1000)
        allow(media_plan).to receive(:estimated_reach).and_return(200)

        expect(media_plan.cpr).to eq(5)
      end
    end

    describe '#cpe' do
      it 'returns 0 if there is no scope of work' do
        expect(media_plan.cpe).to eq(0)
      end

      it 'returns 0 if total sell price is 0' do
        allow(media_plan).to receive(:total_sell_price).and_return(0)
        expect(media_plan.cpe).to eq(0)
      end

      it 'returns 0 if estimated engagement rate is 0' do
        allow(media_plan).to receive(:estimated_engagement_rate).and_return(0)
        expect(media_plan.cpe).to eq(0)
      end

      it 'returns cpe' do
        allow(social_media_account).to receive(:estimated_total_engagement).and_return(200)
        allow(social_media_account_2).to receive(:estimated_total_engagement).and_return(200)
        allow(media_plan).to receive(:social_media_accounts).and_return([social_media_account, social_media_account_2])
        allow(media_plan).to receive(:total_sell_price).and_return(1000)

        expect(media_plan.cpe).to eq(2)
      end
    end
  end
end
