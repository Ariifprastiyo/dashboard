require 'rails_helper'

RSpec.describe BulkPublicationService do
  describe '#call' do
    let(:account) { create(:social_media_account, :instagram, username: 'fadiljaidi') }
    let(:campaign) { create(:campaign) }
    let(:media_plan) { create(:media_plan, campaign: campaign) }
    let(:scope_of_work) { create(:scope_of_work, media_plan: media_plan, social_media_account: account) }
    let(:bulk_publication) do
      create(
        :bulk_publication,
        campaign: campaign,
        total_row: 1,
        bulk_publication_file: Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'files', 'campaign_1_template.xlsx'), 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
      )
    end
    let(:index) { 0 }

    context 'when valid data is provided' do
      let(:scope_of_work_item) { create(:scope_of_work_item, scope_of_work: scope_of_work, sell_price: 1000) }
      let(:row) { ['123', 'fadiljaidi', 'instagram', 'feed_video', scope_of_work_item.id, 'Cm6gLZrI21p'] }
      let(:service) { BulkPublicationService.new(bulk_publication: bulk_publication, campaign: campaign, row: row, index: index) }

      it 'creates a social media publication' do
        expect { service.call }.to change(SocialMediaPublication, :count).by(1)
      end

      it 'updates bulk_publication current_row' do
        service.call
        expect(bulk_publication.current_row).to eq(index + 1)
      end
    end

    context 'when invalid data is provided' do
      let(:row) { ['123', 'fadiljaidi', 'instagram', 'feed_video', 11111, 'Cm6gLZrI21p'] }
      let(:service) { BulkPublicationService.new(bulk_publication: bulk_publication, campaign: campaign, row: row, index: index) }

      it 'does not create a social media publication' do
        expect { service.call }.not_to change(SocialMediaPublication, :count)
      end

      it 'increments total_error in bulk_publication' do
        expect { service.call }.to change { bulk_publication.total_error }.by(1)
      end
    end

    context 'when an exception occurs' do
      let(:row) { ['123', 'fadiljaidi', 'instagram', 'feed_video', 11111, 'Cm6gLZrI21p'] }
      let(:service) { BulkPublicationService.new(bulk_publication: bulk_publication, campaign: campaign, row: row, index: index) }

      it 'captures the exception with Sentry' do
        expect(Sentry).to receive(:capture_exception)
        service.call
      end

      it 'increments total_error in bulk_publication' do
        expect { service.call }.to change { bulk_publication.total_error }.by(1)
      end
    end
  end

  # Additional tests for #transform_data, #social_media_account_id, and #create_error_message methods if needed
end
