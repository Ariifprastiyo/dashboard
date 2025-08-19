require 'rails_helper'

RSpec.describe SocialMediaPublicationDailySyncJob, type: :job do
  let(:campaign) { create(:campaign) }
  let(:media_plan) { create(:media_plan, campaign: campaign) }

  describe '#perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    after do
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    end

    it 'enqueue spesific job and update publication metadata' do
      Timecop.freeze Time.local(2021, 1, 1, 0, 0, 0)
      account = create(:social_media_account, :tiktok, username: 'capcapungofficial')
      scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: account)
      publication = create(:social_media_publication, social_media_account: account, platform: :tiktok, url: '7214412866936442139', campaign: campaign, scope_of_work: scope_of_work)

      # Clearing jobs that triggered in after create callback
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      # Make it zero to make sure it will be updated
      publication.update!(likes_count: 0, last_sync_at: 5.day.ago)

      SocialMediaPublicationDailySyncJob.new.perform(publication.id)

      publication.reload
      expect(publication.likes_count).to eq 10240
      expect(publication.last_sync_at).to eq Time.now

      # enqueue job
      expect(CreateMediaCommentsAndPublicationHistoryForTiktokJob).to have_been_enqueued.with(publication.id)
    end

    it 'enqueue spesific job and update publication metadata when data from instagram' do
      Timecop.freeze Time.local(2021, 1, 1, 0, 0, 0)

      account = create(:social_media_account, :instagram, username: 'capcapung')
      scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: account)
      publication = create(:social_media_publication, social_media_account: account, platform: :instagram, url: 'CjK3jbupoUr', campaign: campaign, scope_of_work: scope_of_work)

      # Clearing jobs that triggered in after create callback
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      # Make it zero to make sure it will be updated
      publication.update!(likes_count: 0, last_sync_at: 5.day.ago)

      SocialMediaPublicationDailySyncJob.new.perform(publication.id)

      publication.reload
      expect(publication.likes_count).to eq 4514
      expect(publication.last_sync_at).to eq Time.now

      # enqueue job
      expect(CreateMediaCommentsAndPublicationHistoryForInstagramJob).to have_been_enqueued.with(publication.id)
    end

    it 'raise error when got API network instagram error' do
      Timecop.freeze Time.local(2021, 1, 1, 0, 0, 0)

      account = create(:social_media_account, :instagram, username: 'capcapung')
      scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: account)
      publication = create(:social_media_publication, social_media_account: account, platform: :instagram, url: 'CjK3jbupoUr', campaign: campaign, scope_of_work: scope_of_work)

      # Clearing jobs that triggered in after create callback
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      # Make it zero to make sure it will be updated
      publication.update!(likes_count: 0, last_sync_at: 5.day.ago)

      # Mocking the request to make the request failed
      allow(ActiveInstagram).to receive(:media_by_code).and_raise(ActiveInstagram::Drivers::ServerError)

      expect {
        SocialMediaPublicationDailySyncJob.new.perform(publication.id)
      }.to raise_error ActiveInstagram::Drivers::ServerError

      publication.reload
      expect(publication.last_error_during_sync).to be_present
    end

    context 'when tiktok error' do
      before do
        Timecop.freeze Time.local(2021, 1, 1, 0, 0, 0)
        account = create(:social_media_account, :tiktok, username: 'capcapungofficial')
        scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: account)
        @publication = create(:social_media_publication, social_media_account: account, platform: :tiktok, url: '7214412866936442139', campaign: campaign, scope_of_work: scope_of_work)
      end

      it 'raise error when got tiktok API error' do
        # Clearing jobs that triggered in after create callback
        ActiveJob::Base.queue_adapter.enqueued_jobs.clear

        # Mocking ActiveTiktok to make the request unathorized
        allow(ActiveTiktok).to receive(:media_by_id).and_raise(ActiveTiktok::Drivers::UnauthorizedError)

        # Make it zero to make sure it will be updated
        @publication.update!(likes_count: 0, last_sync_at: 5.day.ago)
        expect {
          SocialMediaPublicationDailySyncJob.new.perform(@publication.id)
          @publication.reload
        }.to change(@publication, :last_error_during_sync).from(nil).to("Tiktok Server Error for 7214412866936442139 - ActiveTiktok::Drivers::UnauthorizedError")
      end
    end


    it 'should not raise error if theres post not found on TikTok' do
      account = create(:social_media_account, :tiktok, username: 'capcapungofficial')
      scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: account)
      publication = build(:social_media_publication, social_media_account: account, platform: :tiktok, url: '214412866936442139', campaign: campaign, scope_of_work: scope_of_work)
      publication.save(validate: false)

      # Clearing jobs that triggered in after create callback
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      # Make it zero to make sure it will be updated
      publication.update!(likes_count: 0, last_sync_at: 5.day.ago)

      expect {
        SocialMediaPublicationDailySyncJob.new.perform(publication.id)
      }.to_not raise_error
    end
  end
end
