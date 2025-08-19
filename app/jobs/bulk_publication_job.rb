# frozen_string_literal: true

class BulkPublicationJob < ApplicationJob
  queue_as :default

  discard_on StandardError

  def perform(bulk_publication_id, campaign_id)
    campaign = Campaign.find_by(id: campaign_id)
    bulk_publication = BulkPublication.find(bulk_publication_id)
    file = bulk_publication.bulk_publication_file

    file.open do |f|
      xls = Roo::Spreadsheet.open(f.path, extension: :xlsx)
      xls.sheet('template').parse.each_with_index do |row, index|
        bulk_publication_service = BulkPublicationService.new(bulk_publication: bulk_publication, campaign: campaign, row: row, index: index)
        bulk_publication_service.call
      end
    end
  end
end
