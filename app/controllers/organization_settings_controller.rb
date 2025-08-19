# frozen_string_literal: true

class OrganizationSettingsController < ApplicationController
  before_action :set_organization_setting, only: %i[ edit update ]

  # GET /organization_settings/1/edit
  def edit
  end

  # PATCH/PUT /organization_settings/1 or /organization_settings/1.json
  def update
    respond_to do |format|
      if @organization_setting.update(organization_setting_params)
        format.html { redirect_to edit_organization_setting_url(@organization_setting), notice: "Organization setting was successfully updated." }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_organization_setting
      @organization_setting = OrganizationSetting.first
    end

    # Only allow a list of trusted parameters through.
    def organization_setting_params
      params.require(:organization_setting).permit(:name, :logo, :logo_login)
    end
end
