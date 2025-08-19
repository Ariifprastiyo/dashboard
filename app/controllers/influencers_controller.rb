# frozen_string_literal: true

class InfluencersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_influencer, only: %i[ show edit update destroy ]

  # GET /influencers
  def index
    @q = Influencer.kept.order(created_at: :desc).ransack(params[:q])
    @influencers = @q.result(distinct: true).page(params[:page]).per(50)
    authorize @influencers
  end

  # GET /influencers/1
  def show
    authorize @influencer
  end

  # GET /influencers/new
  def new
    @influencer = Influencer.new
    authorize @influencer
  end

  # GET /influencers/1/edit
  def edit
    authorize @influencer
  end

  # POST /influencers
  def create
    @influencer = Influencer.new(influencer_params)
    authorize @influencer

    if @influencer.save
      redirect_to influencer_url(@influencer), notice: "Influencer was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /influencers/1
  def update
    authorize @influencer
    if @influencer.update(influencer_params)
      redirect_to influencer_url(@influencer), notice: "Influencer was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /influencers/1
  def destroy
    authorize @influencer
    @influencer.discard_with_dependencies
    redirect_to influencers_url, notice: "Influencer was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_influencer
      @influencer = Influencer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def influencer_params
      params.require(:influencer).permit(:name, :email, :phone_number, :pic_phone_number, :gender, :pic, :category, :no_ktp, :no_npwp, :bank_code, :account_number, :address, :have_npwp)
    end
end
