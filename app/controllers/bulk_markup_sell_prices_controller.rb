# frozen_string_literal: true

class BulkMarkupSellPricesController < ApplicationController
  before_action :authenticate_user!

  def new
    @media_plan = MediaPlan.find(params[:media_plan_id])
  end

  def create
    @media_plan = MediaPlan.find(params[:media_plan_id])
    social_media_account_sizes = bulk_markup_sell_price_params[:social_media_account_sizes]
    sell_price_percentages = bulk_markup_sell_price_params[:sell_price_percentages]

    @media_plan.bulk_markup_sell_price(social_media_account_sizes, sell_price_percentages)

    redirect_to media_plan_path(@media_plan), notice: 'Bulk Markup sell price running in the background'
  end

  private
    def bulk_markup_sell_price_params
      params.require(:media_plan).permit(social_media_account_sizes: {}, sell_price_percentages: {})
    end
end
