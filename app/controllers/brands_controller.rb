# frozen_string_literal: true

class BrandsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_brand, only: %i[ show edit update destroy ]

  # GET /brands or /brands.json
  def index
    @brands = policy_scope(Brand).kept.includes(:logo_attachment).order(created_at: :desc)
    authorize(@brands)
  end

  # GET /brands/1 or /brands/1.json
  def show
    authorize(@brand)
    @active_campaigns = @brand.campaigns.where.not(status: :completed).order(created_at: :desc)
    @completed_campaigns = @brand.campaigns.where(status: :completed).order(created_at: :desc)
  end

  # GET /brands/new
  def new
    @brand = Brand.new
    authorize(@brand)
  end

  # GET /brands/1/edit
  def edit
    authorize(@brand)
  end

  # POST /brands or /brands.json
  def create
    @brand = Brand.new(brand_params)
    authorize(@brand)

    respond_to do |format|
      if @brand.save
        format.html { redirect_to brand_url(@brand), notice: "Brand was successfully created.", status: :see_other }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /brands/1 or /brands/1.json
  def update
    authorize(@brand)
    respond_to do |format|
      if @brand.update(brand_params)
        format.html { redirect_to brand_url(@brand), notice: "Brand was successfully updated.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /brands/1 or /brands/1.json
  def destroy
    authorize(@brand)
    @brand.discard

    respond_to do |format|
      format.html { redirect_to brands_url, notice: "Brand was successfully destroyed." }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_brand
      @brand = policy_scope(Brand).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def brand_params
      params.require(:brand).permit(:name, :description, :instagram, :tiktok, :logo).merge(organization: current_user.organization)
    end
end
