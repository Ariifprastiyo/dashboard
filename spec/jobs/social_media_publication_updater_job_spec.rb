require 'rails_helper'

RSpec.describe SocialMediaPublicationUpdaterJob, type: :job do
  let(:media_publication) { double(SocialMediaPublication, sync_daily_update: true) }
  let(:media_publications) { [media_publication] }

  it 'updates social media publication that has not been synced in the last 24 hours' do
    Timecop.freeze do
      allow(SocialMediaPublication).to receive(:need_sync_daily_update).and_return(media_publications)

      expect(media_publication).to receive(:sync_daily_update)

      SocialMediaPublicationUpdaterJob.new.perform
    end
  end
end
