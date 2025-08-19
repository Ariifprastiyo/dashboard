# frozen_string_literal: true

class ManagementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_management, only: %i[ show edit update destroy ]

  # GET /managements or /managements.json
  def index
    @managements = Management.kept
  end

  # GET /managements/1 or /managements/1.json
  def show
    @q = @management.social_media_accounts.ransack(params[:q])
    @social_media_accounts = @q.result.order(created_at: :desc).page(params[:page]).per(50)

    add_breadcrumb 'Managements', managements_path
    add_breadcrumb @management.name, management_path(@management)
  end

  # GET /managements/new
  def new
    @management = Management.new
    authorize @management
  end

  # GET /managements/1/edit
  def edit
    authorize @management
  end

  # POST /managements or /managements.json
  def create
    @management = Management.new(management_params)
    authorize @management

    respond_to do |format|
      if @management.save
        format.html { redirect_to management_url(@management), notice: "Management was successfully created." }
        format.json { render :show, status: :created, location: @management }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @management.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /managements/1 or /managements/1.json
  def update
    authorize @management

    respond_to do |format|
      if @management.update(management_params)
        format.html { redirect_to management_url(@management), notice: "Management was successfully updated." }
        format.json { render :show, status: :ok, location: @management }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @management.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /managements/1 or /managements/1.json
  def destroy
    authorize @management

    @management.discard

    respond_to do |format|
      format.html { redirect_to managements_url, notice: "Management was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_management
      @management = Management.kept.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def management_params
      params.require(:management).permit(:name, :pic_name, :pic_email, :phone, :no_ktp, :no_npwp, :bank_code, :account_number, :address)
    end
end
