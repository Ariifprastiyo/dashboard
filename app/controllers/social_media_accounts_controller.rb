# frozen_string_literal: true

class SocialMediaAccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_social_media_account, only: %i[ show edit update destroy ]

  rescue_from ActiveInstagram::Drivers::ProfileNotFoundError, with: :instagram_profile_not_found
  rescue_from ActiveInstagram::Drivers::ServerError, with: :server_error

  # GET /influencers or /influencers.json
  def index
    @q = SocialMediaAccount.kept.includes(:categories, :influencer, profile_picture_attachment: :blob).ransack(params[:q])
    @social_media_accounts = @q.result(distinct: true).order(created_at: :desc).page(params[:page]).per(50)
    authorize @social_media_accounts
  end

  # GET /influencers/1 or /influencers/1.json
  def show
  end

  # GET /influencers/new
  def new
    @influencer = Influencer.find(params[:influencer_id])
    @social_media_account = SocialMediaAccount.new
    authorize @social_media_account
  end

  # GET /influencers/1/edit
  def edit
    authorize @social_media_account
    @influencer = Influencer.find(params[:influencer_id])
  end

  # POST /influencers or /influencers.json
  def create
    @influencer = Influencer.find(params[:influencer_id])
    @social_media_account = SocialMediaAccount.new(social_media_account_params)

    authorize @social_media_account

    @social_media_account.influencer = @influencer

    respond_to do |format|
      if @social_media_account.save
        format.html { redirect_to influencer_url(@influencer), notice: "SocialMediaAccount was successfully created." }
        format.json { render :show, status: :created, location: @social_media_account }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @social_media_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /influencers/1 or /influencers/1.json
  def update
    authorize @social_media_account
    @influencer = Influencer.find(params[:influencer_id])

    respond_to do |format|
      if @social_media_account.update(social_media_account_params)
        format.html { redirect_back(fallback_location: influencer_url(@influencer), notice: "SocialMediaAccount was successfully updated.") }
        format.json { render :show, status: :ok, location: @social_media_account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @social_media_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /influencers/1 or /influencers/1.json
  def destroy
    authorize @social_media_account
    @social_media_account.discard

    respond_to do |format|
      format.html { redirect_to influencers_url, notice: "Influencer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_social_media_account
      @social_media_account = SocialMediaAccount.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def social_media_account_params
      params.require(:social_media_account).permit(:platform, :story_price, :story_session_price, :username,
                                                   :feed_photo_price, :feed_video_price, :reel_price,
                                                   :live_price, :owning_asset_price, :tap_link_price,
                                                   :link_in_bio_price, :live_attendance_price, :host_price, :comment_price,
                                                   :photoshoot_price, :other_price, :estimated_engagement_rate_branding_post, category_ids: [])
    end

    def instagram_profile_not_found
      respond_to do |format|
        format.html { redirect_to new_influencer_social_media_account_path(influencer_id: params[:influencer_id]), notice: "Instagram profile not found" }
      end
    end

    def tikapi_profile_not_found
      respond_to do |format|
        format.html { redirect_to new_influencer_social_media_account_path(influencer_id: params[:influencer_id]), notice: "Tiktok profile not found" }
      end
    end

    def server_error
      respond_to do |format|
        format.html { redirect_to new_influencer_social_media_account_path(influencer_id: params[:influencer_id]), notice: "Instagram Server error" }
      end
    end
end
