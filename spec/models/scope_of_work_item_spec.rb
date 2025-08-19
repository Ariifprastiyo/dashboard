require 'rails_helper'

RSpec.describe ScopeOfWorkItem, type: :model do
  describe '::PRICES' do
    it 'should defines the prices' do
      prices = [ 'story', 'story_session', 'feed_photo',
        'feed_video', 'reel', 'live', 'owning_asset',
        'tap_link', 'link_in_bio', 'live_attendance', 'host',
        'comment', 'photoshoot', 'other' ]

      expect(ScopeOfWorkItem::PRICES).to eq(prices)
    end
  end

  it { should belong_to(:scope_of_work) }
  xit { should validate_presence_of(:name) }
  xit { should validate_presence_of(:quantity) }
  xit { should validate_presence_of(:price) }
  xit { should validate_inclusion_of(:name).in_array(ScopeOfWorkItem::PRICES) }

  let(:media_plan) { create(:media_plan) }
  let!(:instagram_account_1) { create(:social_media_account, :instagram, username: 'adhytia') }
  let!(:instagram_account_2) { create(:social_media_account, :instagram, username: 'tasyakamila') }

  describe 'after_save' do
    before do
      sow = create(:scope_of_work, media_plan: media_plan, social_media_account: instagram_account_1)
      sow.scope_of_work_items << create(:scope_of_work_item, scope_of_work: sow, name: 'feed_photo', price: 1000)
      sow.scope_of_work_items << create(:scope_of_work_item, scope_of_work: sow, name: 'feed_photo', price: 1000)
      sow.save

      sow = create(:scope_of_work, media_plan: media_plan, social_media_account: instagram_account_2)
      sow.scope_of_work_items << create(:scope_of_work_item, scope_of_work: sow, name: 'feed_photo', price: 1000)
      sow.scope_of_work_items << create(:scope_of_work_item, scope_of_work: sow, name: 'feed_photo', price: 1000)
      sow.save
    end

    before(:all) do
      # make sure we pass the logic for taking the post max 3 months old
      Timecop.freeze(Time.parse("2023-03-10 14:02:08"))
    end

    after(:all) do
      Timecop.return
    end

    it 'calculates estimated engagement rate' do
      expect(media_plan.estimated_engagement_rate).to eq(3.527525257291549)
    end

    it 'calculates estimated impressions' do
      expect(media_plan.estimated_impression).to eq(1908680)
    end

    it 'calculates estimated reach' do
      media_plan.reload
      expect(media_plan.estimated_reach).to eq(10538360)
    end
  end

  describe 'Update budget spent' do
    let(:sow) { create(:scope_of_work, media_plan: media_plan, social_media_account: instagram_account_1) }
    context 'when sow item is posted' do
      it 'updates the scope of work budget spent' do
        feed_video = create(:scope_of_work_item, scope_of_work: sow, name: 'feed_video', price: 3000, sell_price: 4000)

        feed_video.posted_at = Time.now
        feed_video.save

        expect(sow.reload.budget_spent).to eq(3000)
        expect(sow.reload.budget_spent_sell_price).to eq(4000)
      end

      it 'updates campaign budget spent' do
        # campaign need to have selected media plan
        campaign = media_plan.campaign
        campaign.selected_media_plan = media_plan
        campaign.save

        feed_video = create(:scope_of_work_item, scope_of_work: sow, name: 'feed_video', price: 3000, sell_price: 4000)

        feed_video.posted_at = Time.now
        feed_video.save

        expect(sow.campaign.reload.budget_spent).to eq(3000)
        expect(sow.campaign.reload.budget_spent_sell_price).to eq(4000)
      end
    end

    context 'when sow item is not posted' do
      it 'does not update the budget spent' do
        create(:scope_of_work_item, scope_of_work: sow, name: 'feed_photo', price: 1000, sell_price: 2000)

        expect(sow.reload.budget_spent).to eq(0)
        expect(sow.reload.budget_spent_sell_price).to eq(0)
      end
    end
  end
end
