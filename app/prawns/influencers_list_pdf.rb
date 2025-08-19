# frozen_string_literal: true

require "open-uri"

class InfluencersListPdf < Prawn::Document
  def initialize(media_plan, campaign, social_media_accounts, view)
    super(top_margin: 70, page_size: "A3", page_layout: :landscape)

    @media_plan = media_plan
    @campaign = @media_plan.campaign
    @social_media_accounts = @media_plan.social_media_accounts
    @view = view

    @rate_price_count = 0
    @media_plan.scope_of_work_template.keys.each do |item|
      show_rate_price = @campaign.send(:"show_rate_price_#{item}")
      @rate_price_count += 1 if show_rate_price
    end

    header
    move_down 20
    font_size 5
    social_media_account_table
    total_summary
    notes
    sign_place_holder
  end

  def header
    logo
    project_details
  end

  def social_media_account_table
    data = []

    # insert header
    table_head = [
      "No",
      "Influencer Name",
      "Social Media",
      "Category",
      "Follower",
      "Engagement Rate",
      "ER Branding Post",
      "Est. Impression",
      "Est. Reach",
      "Est. Engagement Rate",
      { content: "Rate Card", colspan: @rate_price_count },
      { content: "Total Budget", rowspan: 2 },
      { content: "Notes", rowspan: 2 }
    ]
    data << table_head

    # insert platform name
    rate_cards = []
    rate_cards << { content: "<strong>#{@campaign.platform.capitalize}</strong>", colspan: 10 }
    # insert rate cards
    ScopeOfWorkItem::PRICES.each do |item|
      show_rate_price = @media_plan.campaign.send(:"show_rate_price_#{item}")
      rate_cards << { content: item.humanize } if show_rate_price
    end

    data << rate_cards

    # initial title for sosmed size is must be 1
    size_title_positions = [2]

    # insert social media account data by size
    sizes = SocialMediaAccount.sizes
    sizes.reverse_each do |k, v|
      accounts = @social_media_accounts.send(k)
      next if accounts.empty?

      # store position of size (Mega, Macro, etc) title header row
      size_title_positions << size_title_positions.last + accounts.count + 2

      # Insert size title header row
      data << [{ content: "<strong>#{k.to_s.upcase} Influencers</strong>", colspan: 12 + @rate_price_count }]

      # insert sow for this size category to data
      scope_of_works = @media_plan.scope_of_works.by_social_media_account_size(k)
      scope_of_work_rows_for(scope_of_works).each { |sow| data << sow } if scope_of_works.present?

      # insert total for each column
      # Need to recalculate based on total impression and engagement rate
      total_estimated_comments_count = accounts.sum(:estimated_comments_count)
      total_estimated_likes_count = accounts.sum(:estimated_likes_count)
      total_share_count = accounts.sum(:estimated_share_count)
      total_impressions = accounts.sum(:estimated_impression)
      total_average_er = (total_estimated_comments_count + total_estimated_likes_count + total_share_count) / accounts.sum(:followers).to_f * 100
      total_average_er = accounts.sum(:estimated_engagement_rate_average) if accounts.size == 1

      data << [{ content: "<strong>TOTAL IMPRESSION & REACH CATEGORY #{k.to_s.upcase}</strong>", colspan: 7 },
        { content: "<strong>#{@view.number_with_delimiter total_impressions.to_i}</strong>", colspan: 1, background_color: "FFFF00" },
        { content: "<strong>#{@view.number_with_delimiter accounts.sum(:estimated_reach).to_i}</strong>", colspan: 1, background_color: "FFFF00" },
        { content: "<strong>#{@view.number_to_percentage(total_average_er, precision: 2)}</strong>", colspan: 1, background_color: "FFFF00" },
        { content: "<strong></strong>", colspan: @rate_price_count },
        { content: "<strong></strong>" },
        { content: "<strong></strong>" },
      ]
    end

    # Render table and set style
    table(data,
      header: true,
      width: 1120,
      cell_style: { size: 8, inline_format: true, align: :center, valign: :center, border_width: 0.5, border_color: "000000" }) do
        row(0).font_style = :bold
        row(0).background_color = "92c47c"

        row(1).font_style = :bold
        row(1).background_color = "f4cccc"

        size_title_positions.each do |pos|
          row(pos).font_style = :bold
          row(pos).background_color = "d9e9d3"
        end
      end
  end

  def total_summary
    data = []

    total_media_plan_budget = @media_plan.scope_of_works.sum(:total_sell_price)
    management_fee = (total_media_plan_budget * 10) / 100
    total_price_before_vat = total_media_plan_budget + management_fee
    vat = (total_price_before_vat * 11) / 100
    total_budget_after_vat = total_price_before_vat + vat

    data << [
      'TOTAL MEDIA BUDGET',
      @view.number_to_currency(total_media_plan_budget.to_i)
    ]

    data << [
      'MANAGEMENT FEE (10%)',
      @view.number_to_currency(management_fee),
    ]

    data << [
      'Total Price Before VAT',
      @view.number_to_currency(total_price_before_vat),
    ]

    data << [
      'VAT (11%)',
      @view.number_to_currency(vat),
    ]

    data << [
      'Total Budget After VAT',
      @view.number_to_currency(total_budget_after_vat),
    ]

    # Render table and set style
    table(data,
      width: 1120,
      cell_style: {
        size: 8,
        inline_format: true,
        align: :center,
        valign: :center,
        border_width: 0.5,
        border_color: "000000",
        background_color: '87ceeb',
        font_style: :bold })
  end

  def notes
    move_down 20
    text "<strong><u>Notes & Media Terms:</u></strong>", size: 8, inline_format: true, leading: 5
    text @campaign.notes_and_media_terms, size: 8, leading: 5

    move_down 20
    text "<strong><u>Payment Terms:</u></strong>", size: 8, inline_format: true, leading: 5
    text @campaign.payment_terms, size: 8, leading: 5
  end

  def sign_place_holder
    move_down 20
    font_size 8
    data = []
    data << ["PT. Teknologi Media Digital", @campaign.client_sign_name]
    data << [@campaign.mediarumu_pic_name, ""]
    data << ["Date : #{Time.now.strftime("%B %d, %Y")}", ""]

    table(data, width: 500, cell_style: { border_width: 0 }) do
      row(0).height = 60
    end
  end

  def scope_of_work_rows_for(scope_of_works)
    data = []
    scope_of_works.each_with_index do |scope_of_work, index|
      row = []
      row.push(index + 1)
      row.push(scope_of_work.social_media_account.influencer.name)
      row.push(scope_of_work.social_media_account.username)
      row.push(scope_of_work.social_media_account.categories.pluck(:name).join(", "))
      row.push(scope_of_work.social_media_account.followers)
      row.push(@view.number_to_percentage(scope_of_work.social_media_account.estimated_engagement_rate, precision: 2))
      row.push(@view.number_to_percentage(scope_of_work.social_media_account.estimated_engagement_rate_branding_post, precision: 2))
      row.push(@view.number_with_delimiter(scope_of_work.social_media_account.estimated_impression.to_i))
      row.push(@view.number_with_delimiter(scope_of_work.social_media_account.estimated_reach.to_i))
      row.push(@view.number_to_percentage(scope_of_work.social_media_account.estimated_engagement_rate_average, precision: 2))

      # Loop through PRICES constant in ScopeOfWorkItem
      prices = ScopeOfWorkItem::PRICES
      prices.each do |key|
        # check if enabled in campaign settings
        show_rate_price = @campaign.send(:"show_rate_price_#{key}")
        next unless show_rate_price

        # push blank if key is not in scope_of_work_items
        if !scope_of_work.scope_of_work_items.pluck(:name).include?(key)
          row.push("")
          next
        end

        # select max sell_price from scope_of_work_items group by name
        # to avoid getting the same kind of sow item twice and makes the report row overflow
        scope_of_work.scope_of_work_items.select('MAX(sell_price) as sell_price, name').group(:name).each do |item|
          if key == item.name
            row.push(@view.number_to_currency(item.sell_price.to_i))
          end
        end
      end

      row.push(@view.number_to_currency(scope_of_work.total_sell_price.to_i))

      row.push(scope_of_work.sow_item_summary)

      data << row
    end
    data
  end

  def logo
    # logo from assets/images
    logo = "#{Rails.root}/app/assets/images/logos/logo.jpeg"
    bounding_box([0, 790], width: 100, height: 150) do
      image logo, height: 100, position: :left
      transparent(0.5) { stroke_bounds } if debug?
    end
  end

  def project_details
    project_details_rows =
    [ ["Company Name", ":", "PT Tekno Solusi Mediarumu"],
      ["Company Address", ":", "Recapital Building 1st Floor, Jalan Adityawarman no. 55 Melawai, Jakarta Selatan"],
      ["Contact Name", ":", @campaign.mediarumu_pic_name],
      ["Phone. no", ":", @campaign.mediarumu_pic_phone],
    ]


    bounding_box([120, 790], width: 420, height: 150) do
      text "Influencer Marketing - #{@campaign.brand.name} - #{@campaign.platform.capitalize}", style: :bold, align: :center
      move_down 5
      text "#{@campaign.start_at.strftime("%B %d, %Y")} - #{@campaign.end_at.strftime("%B %d, %Y")}", align: :center

      move_down 10
      table(project_details_rows,
        column_widths: [150, 20, 240],
        cell_style: { size: 10, border_width: 0, padding: [0, 0, 5, 0] })
      transparent(0.5) { stroke_bounds } if debug?
    end
  end

  def debug?
    false
  end
end
