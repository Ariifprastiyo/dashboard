# frozen_string_literal: true

module Platformable
  extend ActiveSupport::Concern

  included do
    enum :platform, { instagram: 0, tiktok: 1 }
  end

  def reach_metric_name
    'Views'
  end

  def cpi_or_cpv_name
    'CPV'
  end
end
