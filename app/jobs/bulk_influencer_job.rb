# frozen_string_literal: true

class BulkInfluencerJob < ApplicationJob
  discard_on StandardError

  MASTER_DATA = 'MASTER'

  def perform(bulk_influencer_id)
    bulk_influencer = BulkInfluencer.find(bulk_influencer_id)
    file = bulk_influencer.bulk_influencer_file

    file.open do |f|
      @xls = Roo::Spreadsheet.open(f.path, extension: :xlsx)
    end

    @xls.sheet(MASTER_DATA).parse.each_with_index do |row, index|
      bulk_influencer_service = BulkInfluencerService.new(bulk_influencer: bulk_influencer, row: row, index: index)
      bulk_influencer_service.call
    end
  end
end
