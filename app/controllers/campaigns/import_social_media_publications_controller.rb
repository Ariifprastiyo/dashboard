# frozen_string_literal: true

class Campaigns::ImportSocialMediaPublicationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: %i[ index new show create download_template cancel]
  before_action :set_bulk_publication, only: %i[ show destroy download_uploaded_file cancel ]

  def index
    add_breadcrumb 'Campaigns', campaigns_path
    add_breadcrumb @campaign.name, campaign_path(@campaign)
    add_breadcrumb 'Import Social Media Publications', campaign_import_social_media_publications_path(@campaign)

    @bulk_publications = @campaign.bulk_publications.order(created_at: :desc).all
    @bulk_publications
  end

  def new
    @bulk_publication = BulkPublication.new

    add_breadcrumb 'Campaigns', campaigns_path
    add_breadcrumb @campaign.name, campaign_path(@campaign)
    add_breadcrumb 'Import Social Media Publications', campaign_import_social_media_publications_path(@campaign)
  end

  def show
    add_breadcrumb 'Campaigns', campaigns_path
    add_breadcrumb @campaign.name, campaign_path(@campaign)
    add_breadcrumb 'Import Social Media Publications', campaign_import_social_media_publications_path(@campaign)
  end

  def download_template
    @scope_of_work_items = @campaign.selected_media_plan.scope_of_work_items.not_posted
    send_data generate_xlsx(@scope_of_work_items), filename: "#{@campaign.name.parameterize.underscore}_template.xlsx"
  end

  def download_uploaded_file
    return redirect_to campaign_import_social_media_publication_path(@bulk_publication), notice: 'Uploaded file not found' unless @bulk_publication.bulk_publication_file.attached?

    blob = @bulk_publication.bulk_publication_file_blob
    response.headers["Content-Type"] = blob.content_type
    response.headers["Content-Disposition"] = "attachment; filename=#{blob.filename}-#{@bulk_publication.id}.xlsx"

    @bulk_publication.bulk_publication_file.download do |chunk|
      response.stream.write(chunk)
    end
  end

  def create
    bulk_publication = BulkPublication.new

    file = Roo::Spreadsheet.open(bulk_publication_params[:bulk_publication_file])
    total_row = file.sheet('template').last_row - 1 # minus header row
    current_time = Time.now.strftime("%F:T%H:%M:%S")

    bulk_publication.bulk_publication_file.attach(
      io: bulk_publication_params[:bulk_publication_file],
      filename: "bulk_publication_#{current_time}"
    )

    bulk_publication.campaign = @campaign
    bulk_publication.total_row = total_row
    bulk_publication.save

    return redirect_to new_campaign_import_social_media_publication_path,
      notice: 'Please check your upload file, make sure format correct and no empty rows' unless bulk_publication.valid?

    bulk_publication_job = BulkPublicationJob.perform_later(bulk_publication.id, @campaign.id)

    bulk_publication.update(job_id: bulk_publication_job)

    redirect_to campaign_import_social_media_publication_path(@campaign, bulk_publication),
      notice: 'We will upload your data in background job'
  end

  def cancel
    CancelBulkPublicationJob.perform_later(@bulk_publication.job_id)
    redirect_to campaign_import_social_media_publications_path(id: @bulk_publication.campaign.id), notice: 'Bulk publication cancellation on progress'
  end

  def destroy
    if @bulk_publication.bulk_publication_file.attached?
      blob_id = @bulk_publication.bulk_publication_file.blob.id
      bulk_incluencer_file = ActiveStorage::Attachment.find(blob_id)
      bulk_incluencer_file.purge
    end

    @bulk_publication.destroy

    redirect_back notice: "Sucessfully deleted", fallback_location: campaign_import_social_media_publications_path(id: @bulk_publication.campaign.id)
  end

private
  def set_campaign
    @campaign = policy_scope(Campaign).find(params[:campaign_id])
  end

  def set_bulk_publication
    @bulk_publication = BulkPublication.find(params[:id])
  end

  def generate_xlsx(scope_of_work_items)
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(name: 'template') do |sheet|
        header_row = ['no', 'social_media_account', 'platform', 'sow_item_name', 'sow_item_id', 'url'].map(&:underscore)
        sheet.add_row(header_row)

        scope_of_work_items.each_with_index do |item, index|
          sheet.add_row([index + 1, item.social_media_account.username, item.social_media_account.platform, item.name, item.id, ''])
        end
      end
    end.to_stream.string
  end

  def bulk_publication_params
    params.require(:bulk_publication).permit(:bulk_publication_file)
  end
end
