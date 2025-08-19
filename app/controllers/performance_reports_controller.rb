# frozen_string_literal: true

class PerformanceReportsController < ApplicationController
  include ActionView::Helpers::NumberHelper

  before_action :authenticate_user!
  before_action :admin_or_bd_required!

  def show
    @campaign = policy_scope(Campaign).find(params[:campaign_id])

    # months from campaign start_at to end_at attribute
    start_month = @campaign.start_at.beginning_of_month.to_date
    end_month = @campaign.end_at.end_of_month.to_date
    @months = (start_month..end_month).map { |d| d.beginning_of_month }.uniq

    @actual_reports = @months.map do |m|
      {
        month: m,
        updated_reach_plan_dom_id: "#{m.iso8601}_updated_reach_plan",
        updated_reach_plan: updated_reach_plan_for(m),
        date_in_iso: m.iso8601,
        total_reach: number_with_delimiter(@campaign.total_reach_in(m.beginning_of_month, m.end_of_month)),
        total_budget_spent: number_to_currency(@campaign.total_budget_spent_sell_price_in(m.beginning_of_month, m.end_of_month)),
        total_engagement: number_with_delimiter(@campaign.total_engagement_in(m.beginning_of_month, m.end_of_month)),
        total_cpr: number_to_currency(@campaign.total_cpr_in(m.beginning_of_month, m.end_of_month)),
        total_cpe: number_to_currency(@campaign.total_cpe_in(m.beginning_of_month, m.end_of_month)),
        total_crb: number_to_percentage(@campaign.total_crb_in(m.beginning_of_month, m.end_of_month), precision: 2),
      }
    end

    respond_to do |format|
      format.html
      format.pdf { export_pdf }
    end
  end

  private
    def updated_reach_plan_for(month)
      plan = @campaign.updated_target_plan_for_reach_in(month.iso8601)
      return nil if plan.blank?

      number_with_delimiter(plan)
    end

    def export_pdf
      pdf = PerformanceReportPdf.new(campaign: @campaign, actual_reports: @actual_reports)
      filename = "#{@campaign.brand_name}_#{@campaign.name}_performance_report.pdf"
      send_data pdf.render, filename: filename, type: 'application/pdf', disposition: 'attachment'
    end
end
