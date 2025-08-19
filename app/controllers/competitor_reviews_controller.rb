# frozen_string_literal: true

class CompetitorReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_competitor_review, only: %i[ show edit update destroy show_campaign ]

  # GET /competitor_reviews or /competitor_reviews.json
  def index
    @competitor_reviews = policy_scope(CompetitorReview)
  end

  # GET /competitor_reviews/new
  def new
    @competitor_review = CompetitorReview.new
  end

  # GET /competitor_reviews/1/edit
  def edit
  end

  # GET /competitor_reviews/1
  def show
    # Fetch campaigns for this competitor review with associated data
    @campaigns = @competitor_review.campaigns.includes(:selected_media_plan, :brand, :social_media_publications)
  end

  # GET /competitor_reviews/1/campaigns/1
  def show_campaign
    @campaign = @competitor_review.campaigns.find(params[:campaign_id])
    if @campaign.selected_media_plan.blank?
      @scope_of_works = []
    else
      @scope_of_works = @campaign.selected_media_plan.scope_of_works.includes([:social_media_account, :social_media_publications])
    end
    @scope_of_works_data = scope_of_works_data(@scope_of_works)

    respond_to do |format|
      format.html
      format.csv do
        send_data scope_of_works_to_csv(@scope_of_works_data),
                  filename: "#{@campaign.name.parameterize}_scope_of_works.csv",
                  type: 'text/csv',
                  disposition: 'attachment'
      end
    end
  end

  # POST /competitor_reviews or /competitor_reviews.json
  def create
    @competitor_review = CompetitorReview.new(competitor_review_params)

    if @competitor_review.save
      redirect_to competitor_review_url(@competitor_review), notice: "Competitor review was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /competitor_reviews/1 or /competitor_reviews/1.json
  def update
    if @competitor_review.update(competitor_review_params)
      redirect_to edit_competitor_review_url(@competitor_review), notice: "Competitor review was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /competitor_reviews/1 or /competitor_reviews/1.json
  def destroy
    @competitor_review.destroy!

    respond_to do |format|
      format.html { redirect_to competitor_reviews_url, notice: "Competitor review was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_competitor_review
      @competitor_review = policy_scope(CompetitorReview).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def competitor_review_params
      params.require(:competitor_review).permit(:organization_id, :title, campaign_ids: [])
    end

    def scope_of_works_data(scope_of_works)
      scope_of_works.map do |sow|
        {
          account_name: sow.social_media_account.username,
          content: sow.social_media_publications.map(&:public_url).join(', '),
          tier: sow.social_media_account.size,
          reach: sow.reach.to_i,
          engagement: sow.total_engagement.to_i,
          est_investment: sow.budget_spent_sell_price
        }
      end
    end

    def scope_of_works_to_csv(scope_of_works_data)
      require 'csv'
      CSV.generate(headers: true) do |csv|
        csv << ['Account Name', 'Content', 'Tier', 'Reach', 'Engagement', 'Est. Investment']

        scope_of_works_data.each do |row|
          csv << row.values
        end
      end
    end
end
