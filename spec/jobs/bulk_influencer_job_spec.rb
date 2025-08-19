require 'rails_helper'

RSpec.describe BulkInfluencerJob, type: :job do
  include ActiveJob::TestHelper

  let(:bulk_influencer_id) { 1 }
  let(:job) { BulkInfluencerJob.perform_later(bulk_influencer_id) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'queues the job' do
    expect { job }
      .to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
    expect(BulkInfluencerJob).to have_been_enqueued.on_queue("default")
  end

  it 'executes perform' do
    file = double('File', path: 'path/to/file')
    bulk_influencer = double('BulkInfluencer', bulk_influencer_file: file)
    allow(BulkInfluencer).to receive(:find).with(bulk_influencer_id).and_return(bulk_influencer)

    xls = double('Roo::Excelx', sheet: double('Sheet', parse: [['row1'], ['row2']]))
    allow(file).to receive(:open) do |&block|
      block.call(file)
    end
    allow(Roo::Spreadsheet).to receive(:open).with('path/to/file', extension: :xlsx).and_return(xls)

    bulk_influencer_service1 = double('BulkInfluencerService1')
    bulk_influencer_service2 = double('BulkInfluencerService2')
    allow(BulkInfluencerService).to receive(:new).with(bulk_influencer: bulk_influencer, row: ['row1'], index: 0).and_return(bulk_influencer_service1)
    allow(BulkInfluencerService).to receive(:new).with(bulk_influencer: bulk_influencer, row: ['row2'], index: 1).and_return(bulk_influencer_service2)
    allow(bulk_influencer_service1).to receive(:call)
    allow(bulk_influencer_service2).to receive(:call)

    perform_enqueued_jobs { job }

    expect(bulk_influencer_service1).to have_received(:call)
    expect(bulk_influencer_service2).to have_received(:call)
  end

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end
end
