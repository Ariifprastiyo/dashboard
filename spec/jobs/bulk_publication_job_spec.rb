require 'rails_helper'

RSpec.describe BulkPublicationJob, type: :job do
  include ActiveJob::TestHelper

  let(:campaign_id) { 1 }
  let(:bulk_publication_id) { 2 }
  let(:campaign) { instance_double('Campaign') }
  let(:bulk_publication) { instance_double('BulkPublication') }
  let(:bulk_publication_file) { instance_double('BulkPublicationFile') }
  let(:mock_rows) { [['Row1Data1', 'Row1Data2'], ['Row2Data1', 'Row2Data2'], ['Row3Data1', 'Row3Data2']] } # Example data structure

  before do
    allow(Campaign).to receive(:find_by).with(id: campaign_id).and_return(campaign)
    allow(BulkPublication).to receive(:find).with(bulk_publication_id).and_return(bulk_publication)
    allow(bulk_publication).to receive(:bulk_publication_file).and_return(bulk_publication_file)
    allow(bulk_publication).to receive('current_row=').with(any_args).and_return(true)
    allow(bulk_publication).to receive(:save!).and_return(true)

    # Mocking file open and Roo::Spreadsheet to return predefined rows
    allow(bulk_publication_file).to receive(:open).and_yield(double('file', path: 'path/to/tempfile'))
    allow(Roo::Spreadsheet).to receive(:open).with(any_args).and_return(double(sheet: double(parse: mock_rows)))
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  it 'correctly calls BulkPublicationService.new with row and index for each data row' do
    mock_rows.each_with_index do |row, index|
      expect(BulkPublicationService).to receive(:new).with(bulk_publication: bulk_publication, campaign: campaign, row: row, index: index).and_return(double("BulkPublicationService", call: true))
    end

    perform_enqueued_jobs { described_class.perform_now(bulk_publication_id, campaign_id) }
  end
end
