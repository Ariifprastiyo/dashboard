require 'rails_helper'

RSpec.describe SingleSocialMediaAccountUpdaterJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let!(:social_media_account) { create(:social_media_account, :instagram, live_price: '100', story_price: '200') }
    let!(:media_plan) { create(:media_plan, scope_of_work_template: { 'live' => 1, 'story' => 2, 'feed_video' => 0 }) }
    let!(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: social_media_account) }

    context 'when the social media account exists' do
      it 'calls fetch_and_populate_sosmed_data on the social media account' do
        expect_any_instance_of(SocialMediaAccount).to receive(:fetch_and_populate_sosmed_data)

        SingleSocialMediaAccountUpdaterJob.perform_now(social_media_account.id)
      end

      it 'recalculates metrics for media plans that have this social media account' do
        expect(RecalculateMediaPlanMetricJob).to receive(:perform_later).with(media_plan.id)

        SingleSocialMediaAccountUpdaterJob.perform_now(social_media_account.id, media_plan.id)
      end
    end

    context 'when the social media account does not exist' do
      it 'captures a Sentry message' do
        expect(Sentry).to receive(:capture_message).with("SingleSocialMediaAccountUpdaterJob: No social media account found with id: #{social_media_account.id + 1}")

        SingleSocialMediaAccountUpdaterJob.perform_now(social_media_account.id + 1)
      end
    end
  end
end
