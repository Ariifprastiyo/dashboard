require 'rails_helper'

RSpec.describe SocialMediaAccountUpdaterJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let!(:outdated_account) { create(:social_media_account, :instagram_mega_manual, last_sync_at: 25.hours.ago) }
    let!(:recent_account) { create(:social_media_account, :instagram_macro_manual, last_sync_at: 2.hours.ago) }

    it 'enqueues SingleSocialMediaAccountUpdaterJob for outdated social media accounts' do
      expect {
        SocialMediaAccountUpdaterJob.perform_now
      }.to have_enqueued_job(SingleSocialMediaAccountUpdaterJob).with(outdated_account.id)

      expect(SingleSocialMediaAccountUpdaterJob).not_to have_been_enqueued.with(recent_account.id)
    end
  end
end
