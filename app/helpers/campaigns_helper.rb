# frozen_string_literal: true

module CampaignsHelper
  def badge_campaign_status(status)
    case status
    when 'draft'
      bg = 'bg-warning'
    when 'active'
      bg = 'bg-primary'
    when 'completed'
      bg = 'bg-success'
    when 'failed'
      bg = 'bg-danger'
    else
      bg = 'bg-secondary'
    end

    content_tag(:span, status, class: "badge rounded-pill #{bg}")
  end
end
