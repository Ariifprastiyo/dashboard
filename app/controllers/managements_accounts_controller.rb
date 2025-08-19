# frozen_string_literal: true

class ManagementsAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_management

  # GET /managements/new
  def new
    authorize @management

    @q = SocialMediaAccount
      .kept
      .includes(:managements, :categories, profile_picture_attachment: :blob)
      .where(managements: { id: @social_media_accounts })
      .ransack(params[:q])

    @social_media_accounts = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(50)
  end

  # POST /managements or /managements.json
  def create
    authorize @management

    @social_media_account = SocialMediaAccount.find(params[:social_media_account_id])
    @management.social_media_accounts << @social_media_account

    respond_to do |format|
      if @management.save!
        format.turbo_stream
        format.html { redirect_to management_url(@management), notice: "Management was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    social_media_account = SocialMediaAccount.find(params[:social_media_account_id])

    @management.social_media_accounts.destroy(social_media_account.id)

    respond_to do |format|
      format.html { redirect_to management_path(@management) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_management
      @management = Management.kept.find(params[:management_id])
    end

    # Only allow a list of trusted parameters through.
    def management_params
      params.require(:management).permit(:name, :phone, :no_ktp, :no_npwp, :bank_code, :account_number, :address)
    end
end
