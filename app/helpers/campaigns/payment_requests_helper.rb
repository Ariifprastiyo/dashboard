# frozen_string_literal: true

module Campaigns::PaymentRequestsHelper
  def sgid_options_for_collection(collection, campaign, text_method: :name)
    collection.map do |item|
      [
        text_method.respond_to?(:call) ? text_method.call(item) : item.public_send(text_method),
        item.to_sgid(for: :polymorphic_select),
        data: { remaining_amount_that_needs_to_be_paid: remaining_amount_that_needs_to_be_paid_for(item, campaign)  }
      ]
    end
  end

  def remaining_amount_that_needs_to_be_paid_for(beneficiary, campaign)
    payment_request = PaymentRequest.new(beneficiary: beneficiary, campaign: campaign)
    format_to_idr(payment_request.remaining_amount_that_needs_to_be_paid)
  end

  def payement_request_badge(status)
    klass = case status
            when 'pending'
              'text-bg-warning'
            when 'paid'
              'text-bg-success'
            when 'processed'
              'text-bg-info'
            when 'rejected'
              'text-bg-danger'
    end

    content_tag :span, status, class: "badge #{klass}"
  end
end
