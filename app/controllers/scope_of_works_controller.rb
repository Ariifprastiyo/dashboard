# frozen_string_literal: true

class ScopeOfWorksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_scope_of_work_and_relation, except: %i[ index ]

  # GET /influencers or /influencers.json
  def index
    @q = Influencer.includes(:social_media_accounts).kept.order(created_at: :desc).ransack(params[:q])
    @influencers = @q.result(distinct: true).page(params[:page]).per(50)
  end

  # GET /influencers/1 or /influencers/1.json
  def show
  end

  # GET /influencers/new
  def new
    @managements = Management.pluck(:name, :id)
    clear_search_params

    @q = SocialMediaAccount
        .kept
        .includes(:categories, profile_picture_attachment: :blob)
        .left_joins(:managements)
        .by_platform(@campaign.platform)
        .where.not(id: @social_media_accounts)
        .ransack(search_params)

    @social_media_accounts = @q.result(distinct: true)
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(50)

    add_breadcrumb @campaign.name, campaign_path(@campaign)
    add_breadcrumb @media_plan.name, media_plan_path(@media_plan)
    add_breadcrumb 'Add influencers', new_media_plan_scope_of_work_path(@media_plan)
  end

  # GET /influencers/1/edit
  def edit
  end

  # POST /influencers or /influencers.json
  def create
    ActiveRecord::Base.transaction do
      @scope_of_work = ScopeOfWork.new(
        social_media_account: @social_media_account,
        media_plan: @media_plan)

      authorize @scope_of_work

      if search_params.present? && search_params[:managements_id_eq].present?
        @scope_of_work.management_id = search_params[:managements_id_eq]
      end

      respond_to do |format|
        if @scope_of_work.save!
          format.turbo_stream
          format.html { redirect_to media_plan_path(@media_plan), notice: "Scope of Work was successfully created." }
          format.json { render :show, status: :created, location: @scope_of_work }
        else
          format.html { redirect_to action: :new, status: :unprocessable_entity }
          format.json { render json: @scope_of_work.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /influencers/1 or /influencers/1.json
  def update
    respond_to do |format|
      if @scope_of_work.update(scope_of_work_params)
        format.html { redirect_to media_plan_path(@media_plan), notice: "Scope of Work was successfully updated." }
        format.json { render :show, status: :created, location: @scope_of_work }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @scope_of_work.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /influencers/1 or /influencers/1.json
  def destroy
    authorize @scope_of_work
    @scope_of_work.discard_with_dependencies

    respond_to do |format|
      format.html { redirect_to media_plan_path(@media_plan) }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_scope_of_work_and_relation
      @scope_of_work = ScopeOfWork.new
      @scope_of_work = ScopeOfWork.find(params[:id]) if params[:id].present?
      @media_plan = MediaPlan.find(params[:media_plan_id])
      @campaign = @media_plan.campaign
      @social_media_accounts = @media_plan.social_media_accounts
      @social_media_account = SocialMediaAccount.find(params[:social_media_account_id]) if params[:social_media_account_id].present?
      @agreement_payment_terms_note = "Pembayaran pelunasan akan dilakukan pada H-2 (50% Down Payment) dan H+7 setelah PIHAK KEDUA menyelesaikan pekerjaan dan mengirimkan invoice kepada PIHAK PERTAMA."
    end

    # Only allow a list of trusted parameters through.
    def scope_of_work_params
      params.require(:scope_of_work).permit(:total, :notes,
        :agreement_maximum_payment_day, :agreement_absent_day,
        :agreement_end_date, :agreement_payment_terms_note,
        scope_of_work_items_attributes: [:name, :price, :sell_price, :quantity, :id, :scheduled_at, :posted_at, :_destroy])
    end

    def search_params(search_key = 'search')
      params[:q] = session[search_key] if params[:q].blank?
      session[search_key] = params[:q]

      params[:q]
    end

    def clear_search_params(search_key = 'search')
      if session[search_key].present?
        session.delete(search_key)
      end
    end
end
