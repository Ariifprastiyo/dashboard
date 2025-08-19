# frozen_string_literal: true

require 'csv'
class ActivityReportsController < ApplicationController
  before_action :authenticate_user!
  # before_action :admin_or_bd_required!

  include ActionView::Helpers::NumberHelper

  def show
    @campaign = policy_scope(Campaign).find params[:campaign_id]
    publication_histories = PublicationHistory.where(campaign_id: @campaign.id)

    # Make sure that we get all the date from the beginning to the end of day
    if params[:q] && params[:q][:created_at_gteq].present?
      params[:q][:created_at_gteq] = params[:q][:created_at_gteq].to_date.beginning_of_day
    end
    if params[:q] && params[:q][:created_at_lteq].present?
      params[:q][:created_at_lteq] = params[:q][:created_at_lteq].to_date.end_of_day
    end

    @q = publication_histories.ransack(params[:q])

    # Get publication history based on query search (date range),
    # Group by social_media_publication_id and get the newest one
    @publication_histories = PublicationHistory
                              .includes(social_media_publication: [:scope_of_work_item, :social_media_account])
                              .includes(:social_media_account)
                              .where(id: @q.result
                                          .group(:social_media_publication_id)
                                          .maximum(:id)
                                          .values
                                    )
                              .order(social_media_account_size: :desc)

    @mega = populate_info_by_size('mega', @publication_histories)
    @macro = populate_info_by_size('macro', @publication_histories)
    @micro = populate_info_by_size('micro', @publication_histories)
    @nano = populate_info_by_size('nano', @publication_histories)
    @total = populate_total_info_for(@mega, @macro, @micro, @nano)

    respond_to do |format|
      format.html
      format.pdf { export_pdf }
      format.csv { params[:summary] ? export_summary_csv : export_csv }
    end
    end

  private
    def export_pdf
      pdf = ActivityReportPdf.new(periode: periode, campaign: @campaign, mega: @mega, macro: @macro, micro: @micro, nano: @nano, total: @total, tiers: params[:q][:social_media_account_size_in])
      filename = "#{@campaign.brand_name}_#{@campaign.name}_activity_report_#{periode}_.pdf"
      send_data pdf.render, filename: filename, type: 'application/pdf', disposition: 'attachment'
    end

    # Just like export pdf, but this is in CSV format
    # show data for each size and total
    def export_summary_csv
      filename = "#{@campaign.brand_name}_#{@campaign.name}_activity_report_#{periode}_summary.csv"
      csv_data = CSV.generate do |csv|
        csv << ['Size', 'Budget', 'Number of Kol', 'Reach', @campaign.reach_metric_name, 'CPR', 'Engagement Rate', 'CPE', 'CRB']
        csv << ['Mega', @mega[:budget], @mega[:number_of_kol], @mega[:reach], @mega[@campaign.reach_metric_name], @mega[:cpr], @mega[:engagement_rate], @mega[:cpe], @mega[:crb]]
        csv << ['Macro', @macro[:budget], @macro[:number_of_kol], @macro[:reach], @macro[@campaign.reach_metric_name], @macro[:cpr], @macro[:engagement_rate], @macro[:cpe], @macro[:crb]]
        csv << ['Micro', @micro[:budget], @micro[:number_of_kol], @micro[:reach], @micro[@campaign.reach_metric_name], @micro[:cpr], @micro[:engagement_rate], @micro[:cpe], @micro[:crb]]
        csv << ['Nano', @nano[:budget], @nano[:number_of_kol], @nano[:reach], @nano[@campaign.reach_metric_name], @nano[:cpr], @nano[:engagement_rate], @nano[:cpe], @nano[:crb]]
        csv << ['Total', @total[:budget], @total[:number_of_kol], @total[:reach], @total[@campaign.reach_metric_name], @total[:cpr], @total[:engagement_rate], @total[:cpe], @total[:crb]]
      end
      send_data csv_data, filename: filename, type: 'text/csv', disposition: 'inline'
    end

    def export_csv
      filename = "#{@campaign.brand_name}_#{@campaign.name}_activity_report_#{periode}.csv"
      csv_data = CSV.generate do |csv|
        # We are using terms PRICE taken from SELL PRICE
        headers = ['ID', 'Publication ID', 'URL', 'Additional info', 'Account', 'Size', 'Platform', @campaign.reach_metric_name, 'Likes', 'Share', 'Comment', 'Total Engagement', 'ER', 'CRB%', 'CRB count', 'CPV', 'CPR', 'CPE', 'Price', 'Created At', 'Posted At']
        csv << headers
        @publication_histories.each do |ph|
          csv << [ph.id,
                  ph.social_media_publication_id,
                  ph.social_media_publication.public_url,
                  ph.publication_additional_info,
                  ph.social_media_account.username,
                  ph.social_media_account_size,
                  ph.platform,
                  ph.reach,
                  ph.likes_count,
                  ph.share_count,
                  ph.comments_count,
                  ph.total_engagement,
                  number_to_percentage(ph.engagement_rate, precision: 2),
                  number_to_percentage(ph.social_media_publication.crb, precision: 2),
                  ph.related_media_comments_count,
                  ph.social_media_publication.cpv,
                  ph.social_media_publication.cpr,
                  ph.social_media_publication.cpe,
                  ph.social_media_publication.scope_of_work_item.sell_price,
                  ph.created_at.to_fs(:date_format_for_csv),
                  ph.social_media_publication.post_created_at.to_fs(:date_format_for_csv)]
        end
      end

      send_data csv_data, filename: filename, type: 'text/csv', disposition: 'inline'
    end

    def periode
      if params[:q] && params[:q][:created_at_lteq].present?
        start_date = params[:q][:created_at_gteq].to_fs(:day_month_year_short)
        end_date = params[:q][:created_at_lteq].to_fs(:day_month_year_short)
        return "#{start_date} - #{end_date}"
      end

      'Campaign all time'
    end

    def populate_total_info_for(*sizes)
      total = { budget: 0,
                number_of_kol: 0,
                reach: 0,
                impressions: 0,
                cpr: 0,
                engagement_rate: 0,
                cpe: 0,
                crb: 0 }

      total_engagement = 0
      total_comments_count = 0
      total_crb_count = 0
      sizes.each do |size|
        total[:budget] += (size[:budget] || 0)
        total[:number_of_kol] += (size[:number_of_kol] || 0)
        total[:reach] += (size[:reach] || 0)
        total[:impressions] += (size[:impressions] || 0)
        total[:cpr] = total[:budget] / total[:reach].to_f
        total_comments_count += (size[:comments_count] || 0)
        total_crb_count += (size[:crb_count])
        total_engagement += calculate_total_engagement(size)
      end

      total[:engagement_rate] = (total_engagement / total[:impressions].to_f) * 100
      total[:cpe] = total[:budget] / total_engagement.to_f
      total[:crb] = total_comments_count == 0 ? 0 : (total_crb_count / total_comments_count.to_f) * 100
      total[:crb_count] = total_crb_count
      total
    end

    def populate_info_by_size(size, collection)
      return unless SocialMediaAccount.sizes.include? size


      publication_histories = collection.select { |x| x.social_media_account_size == size }
      result = {}

      result[:budget] = 0
      publication_histories.each do |pub|
        sow_item = pub.social_media_publication.scope_of_work_item

        # make sure only posted items being calculated
        next if sow_item.posted_at.blank?
        result[:budget] += sow_item.sell_price || 0
      end

      result[:number_of_kol] = publication_histories.map(&:social_media_account_id).uniq.count
      result[:reach] = publication_histories.pluck(:reach).sum
      result[:cpr] = calculate_cpr(result)
      result[:likes_count] = publication_histories.pluck(:likes_count).sum
      result[:comments_count] = publication_histories.pluck(:comments_count).sum
      result[:share_count] = publication_histories.pluck(:share_count).sum
      result[:impressions] = publication_histories.pluck(:impressions).sum
      result[:engagement_rate] = calculate_engagement_rate(result)
      result[:cpe] = calculate_cpe(result)
      result[:crb_count] = publication_histories.pluck(:related_media_comments_count).sum
      result[:crb] = result[:comments_count].zero? ? 0 : (result[:crb_count] / result[:comments_count].to_f) * 100
      result
    end

    # It seems that we have multiple methods of calculating CPR (look at Campaign model)
    # This is due to we have different sets of data
    # We need to consider the date time and size factor, therefore we have a different sets of data
    # Perhaps we can have a Util class that could do calculation based on data that may come from various sources
    def calculate_cpr(result)
      budget = result[:budget]
      reach = result[:reach]

      return 0 if budget == 0
      return 0 if reach == 0

      budget / reach.to_f
    end

    def calculate_engagement_rate(result)
      return 0 if result[:impressions].zero?

      (calculate_total_engagement(result) / result[:impressions].to_f) * 100
    end

    def calculate_cpe(result)
      return 0 if result[:budget] == 0
      return 0 if calculate_total_engagement(result) == 0

      result[:budget] / calculate_total_engagement(result)
    end

    def calculate_total_engagement(result)
      result[:likes_count] + result[:comments_count] + result[:share_count]
    end
end
