# frozen_string_literal: true

class ReachPlanPerformanceReportsController < ApplicationController
  def edit
    @campaign = Campaign.find(params[:campaign_id])
    @updated_plan = @campaign.updated_target_plan_for_reach_in(params[:date])
  end

  def update
    @campaign = Campaign.find(params[:campaign_id])
    reach_plan = @campaign.updated_target_plan_for_reach || {}
    reach_plan[params[:date]] = params[:reach_plan]
    @campaign.update!(updated_target_plan_for_reach: reach_plan)
    redirect_to campaign_performance_report_path(campaign_id: @campaign)
  end
end
