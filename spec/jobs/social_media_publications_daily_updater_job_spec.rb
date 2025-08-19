require 'rails_helper'

RSpec.describe SocialMediaPublicationsDailyUpdaterJob, type: :job do
  let(:campaign) { create(:campaign) }
  let(:account) { create(:social_media_account, :instagram, username: 'ngomonginuang') }
  let(:media_plan) { create(:media_plan, campaign: campaign) }
  let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }

  describe '#perform' do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    after do
      # Clearing jobs that triggered in after create callback
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    end

    it 'enqueue spesific jobs' do
      campaign = create(:campaign, :active,
        start_at: 1.day.ago,
        end_at: 1.day.from_now
      )
      publication1 = create(:social_media_publication, :instagram,
        url: 'CoXBwY6pXNM',
        social_media_account: account,
        campaign: campaign,
        scope_of_work: scope_of_work,
        manual: false,
        deleted_by_third_party: false
      )
      publication1.update(last_sync_at: 2.day.ago)

      campaign2 = create(:campaign, :completed,
        start_at: 1.day.ago,
        end_at: 1.day.from_now
      )
      publication2 = create(:social_media_publication, :instagram,
        url: 'Cpha7AeJlIh',
        social_media_account: account,
        campaign: campaign2,
        scope_of_work: scope_of_work,
        manual: false,
        deleted_by_third_party: false
      )
      publication2.update(last_sync_at: 2.day.ago)

      campaign3 = create(:campaign, :draft,
        start_at: 1.day.ago,
        end_at: 1.day.from_now
      )
      publication3 = create(:social_media_publication, :instagram,
        url: 'Cp2A9jZprv-',
        social_media_account: account,
        campaign: campaign3,
        scope_of_work: scope_of_work,
        manual: false,
        deleted_by_third_party: false
      )
      publication3.update(last_sync_at: 2.day.ago)

      tiktok_account = create(:social_media_account, :tiktok, username: 'capcapungofficial')
      tiktok_scope_of_work = create(:scope_of_work, media_plan: media_plan, social_media_account: tiktok_account)
      tiktok_publication = create(:social_media_publication,
        social_media_account: tiktok_account,
        platform: :tiktok,
        url: '7214412866936442139',
        campaign: campaign,
        scope_of_work: tiktok_scope_of_work,
        manual: false,
        deleted_by_third_party: false
      )
      tiktok_publication.update(last_sync_at: 2.days.ago)

      # Clear any jobs that might have been enqueued during creation
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear

      SocialMediaPublicationsDailyUpdaterJob.new.perform

      # We expect only publications from active campaigns within the date range to be synced
      expect(SocialMediaPublicationDailySyncJob).to have_been_enqueued.with(tiktok_publication.id)
      expect(SocialMediaPublicationDailySyncJob).to have_been_enqueued.with(publication1.id)
      expect(SocialMediaPublicationDailySyncJob).not_to have_been_enqueued.with(publication2.id)
      expect(SocialMediaPublicationDailySyncJob).not_to have_been_enqueued.with(publication3.id)
    end
  end
end
