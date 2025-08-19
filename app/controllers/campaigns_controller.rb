# frozen_string_literal: true

class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: %i[ show edit update destroy timeline recalculate_the_last_publication_history_metrics sync_social_media_publications]
  before_action :set_brands_and_platforms_and_statuses, only: %i[ new create edit update]

  # GET /campaigns or /campaigns.json
  def index
    @campaigns = policy_scope(Campaign).kept.includes(:brand).order(created_at: :desc)
    authorize(@campaigns)
  end

  # GET /campaigns/1 or /campaigns/1.json
  def show
    authorize(@campaign)
    @media_plans = @campaign.media_plans
    @selected_media_plan = @campaign.selected_media_plan

    if @selected_media_plan
      @q = @selected_media_plan.scope_of_works.includes(social_media_account:  [:profile_picture_attachment]).includes(social_media_publications: [:social_media_account]).ransack(params[:q])
      @scope_of_works = @q.result.order(created_at: :desc).page(params[:page]).per(50)
    end
  end

  # GET /campaigns/new
  def new
    @campaign = Campaign.new
    authorize(@campaign)
  end

  # GET /campaigns/1/edit
  def edit
    authorize(@campaign)
    populate_selected_show_rate_prices(@campaign)
  end

  # POST /campaigns or /campaigns.json
  def create
    if campaign_params[:brand_id].blank?
      @campaign = Campaign.new(campaign_params)
    else
      brand = policy_scope(Brand).kept.find(campaign_params[:brand_id])
      @campaign = Campaign.new(campaign_params.merge(organization_id: brand.organization_id))
    end

    authorize(@campaign)

    handle_selected_show_rate_price(@campaign, params[:campaign][:selected_show_rate_prices])

    respond_to do |format|
      if @campaign.save
        format.html { redirect_to campaign_url(@campaign), notice: "Campaign was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /campaigns/1 or /campaigns/1.json
  def update
    authorize(@campaign)
    respond_to do |format|
      handle_selected_show_rate_price(@campaign, params[:campaign][:selected_show_rate_prices])
      if @campaign.update(campaign_params)
        format.html { redirect_to campaign_url(@campaign), notice: "Campaign was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1 or /campaigns/1.json
  def destroy
    authorize(@campaign)
    @campaign.discard_with_dependencies

    respond_to do |format|
      format.html { redirect_to campaigns_url, notice: "Campaign was successfully destroyed." }
    end
  end

  def timeline
    authorize(@campaign)
    @selected_media_plan = @campaign.selected_media_plan

    add_breadcrumb @campaign.name, campaign_path(@campaign)

    redirect_to campaign_url(@campaign) unless @selected_media_plan
  end

  def recalculate_the_last_publication_history_metrics
    @campaign.social_media_publications.map(&:recalculate_the_last_publication_history_metrics)

    redirect_to campaign_url(@campaign), notice: "The last publication history metrics has been recalculated."
  end

  def sync_social_media_publications
    @campaign.sync_all_publications

    redirect_to campaign_url(@campaign), notice: "The social media publications has been synced."
  end

  def analyze_comment_with_ai
    campaign = Campaign.find(params[:id])
    campaign.analyze_comment_with_openai

    redirect_to media_comments_path(campaign), notice: "Comments has been analyzed with AI."
  end

  def analyze_comment_word_cloud
    campaign = Campaign.find(params[:id])

    campaign.create_word_cloud_comments_with_openai

    redirect_to media_comments_path(campaign), notice: "Comments has been analyzed with AI."
  end

  def export_word_cloud
    @campaign = policy_scope(Campaign).find(params[:id])
    authorize(@campaign)

    word_cloud_csv = CSV.generate do |csv|
      csv << ['Word', 'Count']
      @campaign.sorted_word_cloud.each do |word, count|
        csv << [word, count]
      end
    end

    respond_to do |format|
      format.csv { send_data word_cloud_csv, filename: "#{@campaign.name}_word_cloud.csv" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_campaign
      @campaign = policy_scope(Campaign).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def campaign_params
      params.require(:campaign).permit(:name,
        :brand_id,
        :status,
        :start_at,
        :end_at,
        :invitation_expired_at,
        :budget_from_brand,
        :budget,
        :kpi_number_of_social_media_accounts,
        :kpi_reach, :kpi_impression,
        :kpi_engagement_rate,
        :kpi_cpv, :kpi_cpr, :kpi_cpe, :kpi_crb,
        :platform,
        :mediarumu_pic_name, :mediarumu_pic_phone,
        :notes_and_media_terms, :payment_terms, :management_fees,
        :client_sign_name,
        :selected_media_plan_id,
        :selected_show_rate_prices,
        :show_rate_price_story,
        :show_rate_price_story_session,
        :show_rate_price_feed_photo,
        :show_rate_price_feed_video,
        :show_rate_price_reel,
        :show_rate_price_live,
        :show_rate_price_owning_asset,
        :show_rate_price_tap_link,
        :show_rate_price_link_in_bio,
        :show_rate_price_live_attendance,
        :show_rate_price_host,
        :show_rate_price_comment,
        :show_rate_price_photoshoot,
        :show_rate_price_other,
        :keyword,
        :hashtag,
        :comment_ai_prompt
      )
    end

    def handle_selected_show_rate_price(campaign, selected_show_rate_prices)
      return if selected_show_rate_prices.nil?
      selected_show_rate_prices.reject!(&:empty?)
      return if selected_show_rate_prices.blank?

      # make all price to false first
      ScopeOfWorkItem::PRICES.each do |pricing_name|
        campaign.send("show_rate_price_#{pricing_name}=", false)
      end

      # set it true only for selected price
      selected_show_rate_prices.each do |pricing_name|
        campaign.send("show_rate_price_#{pricing_name}=", true)
      end
    end

    def populate_selected_show_rate_prices(campaign)
      campaign.selected_show_rate_prices = []
      ScopeOfWorkItem::PRICES.each do |pricing_name|
        campaign.selected_show_rate_prices << pricing_name if campaign.send("show_rate_price_#{pricing_name}")
      end
    end

    def set_brands_and_platforms_and_statuses
      @brands = policy_scope(Brand).kept
      @platforms = Campaign.platforms
      @statuses = Campaign.statuses
    end
end
