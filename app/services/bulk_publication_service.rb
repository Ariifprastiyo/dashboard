# frozen_string_literal: true

class BulkPublicationService < ApplicationService
  def initialize(bulk_publication:, campaign:, row:, index:)
    @data = transform_data(row)
    @index = index + 1 # header and start from 0
    @bulk_publication = bulk_publication
    @campaign = campaign
  end

  def call
    @bulk_publication.current_row = @index
    @bulk_publication.save!
    scope_of_work_item = ScopeOfWorkItem.find(@data[:sow_item_id])

    ActiveRecord::Base.transaction do
      publication = SocialMediaPublication.new(
        scope_of_work_id: scope_of_work_item.scope_of_work_id,
        social_media_account_id: social_media_account_id(@data[:social_media_account]),
        campaign_id: @campaign.id,
        scope_of_work_item_id: scope_of_work_item.id,
        platform: @data[:platform],
        url: @data[:url]
      )

      if publication.valid?
        publication.save!
      else
        create_error_message(title: 'Publication Data', message: publication.errors.full_messages)
      end
    end
  rescue ArgumentError => e
    Sentry.capture_exception(e)
    create_error_message(title: 'Parameter Error', message: e.message.to_s)
  rescue StandardError => e
    Sentry.capture_exception(e)
    create_error_message(title: 'Error', message: e.message.to_s)
  end

  private
    def transform_data(row)
      data = {}

      data[:number] = row[0]
      data[:social_media_account] = row[1]
      data[:platform] = row[2]
      data[:sow_item_name] = row[3]
      data[:sow_item_id] = row[4]
      data[:url] = row[5]

      data
    end

    def social_media_account_id(username)
      SocialMediaAccount.find_by(username: username).id
    end

    def create_error_message(title:, message:)
      @bulk_publication.total_error += 1
      @bulk_publication.error_messages << "#[#{@index}] No. #{@data[:number]} - #{title} can not be stored, message: #{message}"
      @bulk_publication.save!
 end
end
