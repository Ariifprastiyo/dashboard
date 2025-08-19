# frozen_string_literal: true

module MediaPlansHelper
  def invitation_status_badge(status)
    case status
    when 'pending'
      content_tag :span, 'Pending', class: 'badge bg-secondary'
    when 'accepted'
      content_tag :span, 'Accepted', class: 'badge bg-success'
    when 'rejected'
      content_tag :span, 'Rejected', class: 'badge bg-danger'
    end
  end
end
