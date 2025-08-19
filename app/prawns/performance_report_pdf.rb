# frozen_string_literal: true

class PerformanceReportPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper

  def initialize(campaign:, actual_reports:)
    super(page_size: 'A3', page_layout: :landscape)
    @campaign = campaign
    @actual_reports = actual_reports
    generate_report
  end

  private
    def generate_note
      text 'Notes'
      text '1. Engagement: Live, share, comment, saved'
      text '2. CRB - relevant comment not only related to the brand but also the campaigns'
      move_down 20
    end

    def generate_budget_report
      budget_data = []
      budget_data << [{ content: 'Budget', rowspan: 2, valign: :center }, 'Total Plan', 'Total Actual', 'Remaining']
      budget_data << [
        number_to_currency(@campaign.budget_from_brand),
        number_to_currency(@campaign.budget_spent_sell_price),
        number_to_currency(@campaign.budget_remaining_sell_price)
      ]
      table budget_data do
        row(0).font_style = :bold
        row(0).align = :center
      end
      move_down 20
    end

    def generate_initial_plan_report
      initial_data = []
      initial_data << [{ content: 'Initial Plan', colspan: 5 }]
      initial_data << [{ content: 'Month', rowspan: 2, valign: :center }, { content: 'Target', colspan: 4 }]
      initial_data << ['Reach', 'CPR', 'CPE', '%CRB']

      @actual_reports.each do |report|
        initial_data << [
          report[:month].strftime('%B'),
          @campaign.kpi_reach / @actual_reports.size,
          number_to_currency(@campaign.kpi_cpr),
          number_to_currency(@campaign.kpi_cpe),
          number_to_percentage(@campaign.kpi_crb, precision: 2)
        ]
      end

      initial_data << [
        'Total',
        @campaign.kpi_reach,
        number_to_currency(@campaign.kpi_cpr),
        number_to_currency(@campaign.kpi_cpe),
        number_to_percentage(@campaign.kpi_crb, precision: 2)
      ]

      table initial_data do
        row(0).font_style = :bold
        row(0).align = :center
        row(1).font_style = :bold
        row(1).align = :center
        row(2).font_style = :bold
        row(2).align = :center
      end
      move_down 20
    end

    def generate_actual_report
      data = []
      data << [
        { content: 'Month', rowspan: 2, valign: :center },
        { content: 'Actual', colspan: 6 },
      ]
      data << [
        'Reach',
        'Cost',
        'Engagement*1',
        'CPR',
        'CPE',
        '%CBR*2'
      ]

      @actual_reports.each do |report|
        data << [
          report[:month].strftime('%B'),
          report[:total_reach],
          report[:total_budget_spend],
          report[:total_engagement],
          report[:total_cpr],
          report[:total_cpe],
          report[:total_crb]
        ]
      end

      data << [
        'Total',
        number_with_delimiter(@campaign.reach),
        number_to_currency(@campaign.budget_spent_sell_price),
        number_with_delimiter(@campaign.engagement),
        number_to_currency(@campaign.cpr),
        number_to_currency(@campaign.cpe),
        number_to_percentage(@campaign.crb, precision: 2)
      ]

      table data do
        row(0).font_style = :bold
        row(0).align = :center
        row(1).font_style = :bold
        row(1).align = :center
      end
      move_down(20)
    end

    def generate_initial_vs_actual_report
      data = []
      data << [
        { content: 'Month', rowspan: 2, valign: :center },
        { content: 'Reach', colspan: 3 },
        { content: 'CPR', colspan: 2 },
        { content: 'CPE', colspan: 2 },
        { content: '%CRB', colspan: 2 }
      ]

      data << [
        'Initial Target Plan',
        'Updated Target Plan',
        'Actual',
        'Target',
        'Actual',
        'Target',
        'Actual',
        'Target',
        'Actual'
      ]

      @actual_reports.each do |report|
        data << [
          report[:month].strftime('%B'),
          number_with_delimiter(@campaign.kpi_reach),
          number_with_delimiter(report[:updated_reach_plan]),
          report[:total_reach],
          number_to_currency(@campaign.kpi_cpr),
          report[:total_cpr],
          number_to_currency(@campaign.kpi_cpe),
          report[:total_cpe],
          number_to_percentage(@campaign.kpi_crb, precision: 2),
          report[:total_crb]
        ]
      end

      data << [
        'Total',
        number_with_delimiter(@campaign.kpi_reach),
        '',
        number_with_delimiter(@campaign.reach),
        number_to_currency(@campaign.kpi_cpr),
        number_to_currency(@campaign.cpr),
        number_to_currency(@campaign.kpi_cpe),
        number_to_currency(@campaign.cpe),
        number_to_percentage(@campaign.kpi_crb, precision: 2),
        number_to_percentage(@campaign.crb, precision: 2)
      ]

      last_row = @actual_reports.size + 2

      table data do
        row(0).font_style = :bold
        row(0).align = :center
        row(1).font_style = :bold
        row(1).align = :center
        row(last_row).font_style = :bold
      end
    end

    def generate_report
      generate_note
      generate_budget_report
      generate_initial_plan_report
      generate_actual_report
      generate_initial_vs_actual_report
    end
end
