# frozen_string_literal: true

class MediaPlansController < ApplicationController
  before_action :set_media_plan, only: [:show, :edit, :update, :destroy, :export]

  def new
    @campaign = policy_scope(Campaign).find(params[:campaign_id])
    @media_plan = @campaign.media_plans.build
  end

  def create
    @media_plan = MediaPlan.new(media_plan_params)

    if @media_plan.save
      redirect_to new_media_plan_scope_of_work_path(@media_plan)
    else
      @campaign = policy_scope(Campaign).find(params[:campaign_id])
      redirect_to new_media_plan_path(campaign_id: @campaign.id), notice: "Media Plan was failed created."
    end
  end

  def show
    @campaign = @media_plan.campaign
    @managements = Management.pluck(:name, :id)

    @q = @media_plan.scope_of_works.includes(social_media_account: { profile_picture_attachment: :blob })
                                    .includes(social_media_account: :categories)
                                    .includes(social_media_account: :influencer)
                                    .includes(:agreement_letter_attachment)
                                    .includes(:scope_of_work_items)
                                    .includes(:social_media_account)
                                    .joins(:social_media_account).ransack(params[:q])

    @scope_of_works = @q.result.order(created_at: :desc).page(params[:page]).per(50)

    add_breadcrumb @campaign.name, campaign_path(@campaign)
    add_breadcrumb @media_plan.name, media_plan_path(@media_plan)
  end

  def edit
  end

  def update
    if @media_plan.update(media_plan_params)
      redirect_to media_plan_path(@media_plan), notice: "Media Plan was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize(@media_plan)

    if @media_plan.destroy
      redirect_to campaign_path(@media_plan.campaign), notice: "Media Plan was successfully deleted."
    end

  rescue ActiveRecord::DeleteRestrictionError => e
    redirect_to campaign_path(@media_plan.campaign), alert: e.message
  end

  # export media plan to pdf
  def export
    authorize(@media_plan)
    @campaign = @media_plan.campaign
    @social_media_accounts = @media_plan.social_media_accounts

    respond_to do |format|
      format.html
      format.pdf do
        pdf = InfluencersListPdf.new(@media_plan, @campaign, @social_media_accounts, view_context)
        send_data(pdf.render,
          filename: "media_plan.pdf",
          type: "application/pdf",
          disposition: "inline")
      end
    end
  end

  private
    def media_plan_params
      params.require(:media_plan).permit(:name, :campaign_id, scope_of_work_template: {})
    end

    def set_media_plan
      @media_plan = policy_scope(MediaPlan).find(params[:id])
    end
end
