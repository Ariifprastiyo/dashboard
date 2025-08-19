# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CancelBulkPublicationJob, type: :job do
  before do
    # allow(Sidekiq).to receive(:redis).and_yield(MockRedis.new)
  end

  describe '#perform' do
    let(:job_id) { 'abfb600963cd174997c1d0af' }
    let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
    let(:bulk_publication) do
      create(
        :bulk_publication,
        campaign: campaign,
        total_row: 1,
        job_id: job_id,
        bulk_publication_file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'campaign_1_template.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      )
    end

    xit 'cancels the job and updates the BulkPublication' do
      described_class.cancel!(job_id)

      expect {
        described_class.perform_later(job_id)
        perform_enqueued_jobs
      }.to change { bulk_publication.reload.cancelled_at }.from(nil)
    end
  end

  describe '.cancel!' do
    xit 'marks the job as cancelled in Redis' do
      jid = 'abfb600963cd174997c1d0af'
      described_class.cancel!(jid)

      expect(Sidekiq.redis { |c| c.exists("cancelled-#{jid}") }).to be_truthy
    end
  end
end
