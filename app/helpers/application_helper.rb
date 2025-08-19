# frozen_string_literal: true

module ApplicationHelper
  def icon_link_to(icon, path, options = {})
    link_to path, options do
      content_tag :i, nil, class: "bi-#{icon}", style: "font-size: 1rem"
    end
  end

  def icon_for(icon, style = '', options = {})
    content_tag :i, nil, class: "bi-#{icon}", style: "font-size: 1rem; #{style}", **options
  end

  def badge_for(item)
    content_tag :span, item, class: "badge bg-secondary"
  end

  def badges_for(array)
    array.map { |item| badge_for(item) }.join.html_safe
  end

  def format_to_idr(amount)
    number_to_currency(amount, unit: "Rp", separator: ",", delimiter: ".", format: "%u %n")
  end

  # bootstrap progress bar
  def show_progress(value, max = 0)
    value = 0 if value.nil?
    value = 0 if value.class == Float && value.nan?
    value = value if value.integer?
    max = 100 if max.zero?
    value = (value.to_f / max * 100).to_i

    content_tag :div, class: "progress" do
      content_tag :div, nil, class: "progress-bar", role: "progressbar", style: "width: #{value}%", "aria-valuenow": value, "aria-valuemin": 0, "aria-valuemax": max do
        "#{value}%"
      end
    end
  end

  def archive_button(object)
    return unless current_user.has_role? :admin
    return if object.id.nil?

    button_to 'Archive', object, class: "btn btn-danger text-white", method: :delete, form: { data: { 'turbo-confirm': 'Are you sure?' } }
  end
end
