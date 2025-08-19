# frozen_string_literal: true

class ActivityReportPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper

  NANO = '0'
  MICRO = '1'
  MACRO = '2'
  MEGA = '3'

  def initialize(periode:, campaign:, mega:, macro:, micro:, nano:, total:, tiers:)
    super(page_size: 'A4', page_layout: :landscape)
    @periode = periode
    @campaign = campaign
    @mega = mega
    @macro = macro
    @micro = micro
    @nano = nano
    @total = total
    @tiers = tiers
    report_table
  end

  def report_table
    table report_data, position: :center do
      row(0).font_style = :bold
      row(0).background_color = 'DDDDDD'
      row(0).align = :center
    end
  end

  def report_data
    data = []
    data << headers
    return data if @tiers.blank?

    if @tiers.include?(MEGA)
      data << [
        'Mega',
        number_to_currency(@mega[:budget]),
        number_with_delimiter(@mega[:number_of_kol]),
        number_with_delimiter(@mega[:reach]),
        number_to_currency(@mega[:cpr]),
        number_to_percentage(@mega[:engagement_rate], precision: 2),
        number_to_currency(@mega[:cpe]),
        number_to_percentage(@mega[:crb], precision: 2)
      ]
    end
    if @tiers.include?(MACRO)
      data << [
        "Macro",
        number_to_currency(@macro[:budget]),
        number_with_delimiter(@macro[:number_of_kol]),
        number_with_delimiter(@macro[:reach]),
        number_to_currency(@macro[:cpr]),
        number_to_percentage(@macro[:engagement_rate], precision: 2),
        number_to_currency(@macro[:cpe]),
        number_to_percentage(@macro[:crb], precision: 2)
      ]
    end
    if @tiers.include?(MICRO)
      data << [
        "Micro",
        number_to_currency(@micro[:budget]),
        number_with_delimiter(@micro[:number_of_kol]),
        number_with_delimiter(@micro[:reach]),
        number_to_currency(@micro[:cpr]),
        number_to_percentage(@micro[:engagement_rate], precision: 2),
        number_to_currency(@micro[:cpe]),
        number_to_percentage(@micro[:crb], precision: 2)
      ]
    end
    if @tiers.include?(NANO)
      data << [
        "Nano",
        number_to_currency(@nano[:budget]),
        number_with_delimiter(@nano[:number_of_kol]),
        number_with_delimiter(@nano[:reach]),
        number_to_currency(@nano[:cpr]),
        number_to_percentage(@nano[:engagement_rate], precision: 2),
        number_to_currency(@nano[:cpe]),
        number_to_percentage(@nano[:crb], precision: 2)
      ]
    end

    data << [
      number_to_currency(@total[:budget]),
      number_with_delimiter(@total[:number_of_kol]),
      number_with_delimiter(@total[:reach]),
      number_to_currency(@total[:cpr]),
      number_to_percentage(@total[:engagement_rate], precision: 2),
      number_to_currency(@total[:cpe]),
      number_to_percentage(@total[:crb], precision: 2)
    ]

    # Add period and platform to the second row
    total_rowspan = data.length - 2
    data[1].prepend({ content: @periode, rowspan: total_rowspan }, { content: platform, rowspan: total_rowspan })

    # Add total platform row to the last row
    data[-1] = data[-1].prepend({ content: "Total #{platform}", colspan: 3 })
    data
  end

  def platform
    @campaign.platform.capitalize
  end

  def headers
    [
      'Periode',
      'Platform',
      'Tier',
      'Price',
      'Number of KOL',
      @campaign.reach_metric_name,
      'CPR',
      'ER',
      'CPE',
      'CRB'
    ]
  end
end
