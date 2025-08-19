# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_super_admin_role

  def index
    @organizations = Organization.all.order(:id)
  end

  def new
    @organization = Organization.new
  end

  def create
    @organization = Organization.new(organization_params)

    if @organization.save
      redirect_to organizations_path, notice: "Organization was successfully created."
    else
      render :new
    end
  end

  def edit
    @organization = Organization.find(params[:id])
  end

  def update
    @organization = Organization.find(params[:id])

    if @organization.update(organization_params)
      redirect_to organizations_path, notice: "Organization was successfully updated."
    else
      render :edit
    end
  end

  private
    def organization_params
      params.require(:organization).permit(:name, :description, :logo)
    end
end
