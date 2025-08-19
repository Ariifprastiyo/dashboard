# frozen_string_literal: true

class BulkInfluencersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bulk_influencer, only: %i[ show destroy ]


  def index
    @bulk_influencers = BulkInfluencer.order(created_at: :desc).all
    authorize @bulk_influencers
  end

  def new
    @bulk_influencer = BulkInfluencer.new
    authorize @bulk_influencer
  end

  def show
    authorize @bulk_influencer
  end

  def create
    bulk_influencer = BulkInfluencer.new
    authorize bulk_influencer

    file = Roo::Spreadsheet.open(bulk_influencer_params[:bulk_influencer_file])
    total_row = file.sheet('MASTER').last_row
    current_time = Time.now.strftime("%F:T%H:%M:%S")

    bulk_influencer.bulk_influencer_file.attach(
      io: bulk_influencer_params[:bulk_influencer_file],
      filename: "bulk_influencer_#{current_time}"
    )
    bulk_influencer.total_row = total_row
    bulk_influencer.save
    return redirect_to new_bulk_influencer_path, notice: 'Please check your upload file, make sure format correct and no empty rows' unless bulk_influencer.valid?

    # TODO: we need to check if .save is returns true, as we need to check if bulk import action is allowed or not
    # TODO: Limit Job Run (.eg only 1 job must run at same time)
    bulk_influencer_job = BulkInfluencerJob.perform_later(bulk_influencer.id)

    bulk_influencer.update(job_id: bulk_influencer_job)

    redirect_to bulk_influencer_path(bulk_influencer), notice: 'We will upload your data in background job'

  rescue RangeError => e
    redirect_to new_bulk_influencer_path, notice: "Please check your uploaded file, make sure format correct and no empty rows. Error: #{e.message}"
  end

  def update
    authorize @bulk_influencer
  end

  def destroy
    authorize @bulk_influencer

    if @bulk_influencer.bulk_influencer_file.attached?
      blob_id = @bulk_influencer.bulk_influencer_file.blob.id
      bulk_incluencer_file = ActiveStorage::Attachment.find(blob_id)
      bulk_incluencer_file.purge
    end

    @bulk_influencer.destroy

    redirect_to bulk_influencers_path, notice: 'Delete was successfully'
  end

  def download
    template_path = Rails.root.join('public', 'files', 'kol_template.xlsx')

    send_file(template_path)
  end

  def download_uploaded_file
    bulk_influencer = BulkInfluencer.find(params[:id])

    return redirect_to bulk_influencer_path(bulk_influencer), notice: 'Uploaded file not found' unless bulk_influencer.bulk_influencer_file.attached?

    blob = bulk_influencer.bulk_influencer_file_blob

    response.headers["Content-Type"] = blob.content_type
    response.headers["Content-Disposition"] = "attachment; filename=#{blob.filename}-#{bulk_influencer.id}.xlsx"

    bulk_influencer.bulk_influencer_file.download do |chunk|
      response.stream.write(chunk)
    end
  end

  def cancel
    bulk_influencer = BulkInfluencer.find(params[:id])

    CancelBulkInfluencerJob.perform_later(bulk_influencer.job_id)

    redirect_to bulk_influencers_path, notice: 'Bulk influencer cancellation on progress'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bulk_influencer
      @bulk_influencer = BulkInfluencer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def bulk_influencer_params
      params.require(:bulk_influencer).permit(:bulk_influencer_file)
    end
end
