# frozen_string_literal: true

class BulkMarkupSellPriceJob < ApplicationJob
  def perform(scope_of_work_id:, sell_price_percentages:)
    scope_of_work = ScopeOfWork.find(scope_of_work_id)

    return if scope_of_work.blank?

    scope_of_work.scope_of_work_items.each do |scope_of_work_item|
      name = scope_of_work_item.name
      sell_price_percentage = sell_price_percentages[:"#{name}"].to_i
      sell_price_amount = (scope_of_work_item.price.to_i * sell_price_percentage) / 100
      sell_price = scope_of_work_item.price.to_i + sell_price_amount.to_i
      scope_of_work_item.update(sell_price: sell_price)
    end

    scope_of_work
  end
end
