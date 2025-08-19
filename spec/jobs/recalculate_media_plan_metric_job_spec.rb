require 'rails_helper'

RSpec.describe RecalculateMediaPlanMetricJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let!(:media_plan) { create(:media_plan, scope_of_work_template: { 'live' => 1, 'story' => 2, 'feed_video' => 0 }) }

    context 'when the media plan exists' do
      it 'calls fetch_and_populate_sosmed_data on the social media account' do
        expect_any_instance_of(MediaPlan).to receive(:recalculate_metrics)

        RecalculateMediaPlanMetricJob.perform_now(media_plan.id)
      end
    end

    context 'when the media plan does not exist' do
      it 'captures a Sentry message' do
        expect(Sentry).to receive(:capture_message).with("RecalculateMediaPlanMetricJob: No media plan found with id: #{media_plan.id + 1}")

        RecalculateMediaPlanMetricJob.perform_now(media_plan.id + 1)
      end
    end
  end
end
