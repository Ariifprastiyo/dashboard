# frozen_string_literal: true

class PaymentRequest < ApplicationRecord
  belongs_to :campaign
  belongs_to :beneficiary, polymorphic: true
  belongs_to :requestor, class_name: 'User'
  belongs_to :payer, class_name: 'User', optional: true

  enum :status, pending: 0, paid: 1, processed: 2, rejected: 3
  enum :pph_option, gross_up: 1, nett: 2

  has_one_attached :invoice
  has_one_attached :payment_proof


  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true
  validates :invoice, attached: true, content_type: [:png, :jpg, :jpeg, :pdf], size: { less_than: 20.megabytes }
  validates :payment_proof, attached: true, content_type: [:png, :jpg, :jpeg, :pdf], size: { less_than: 20.megabytes }, if: -> { status_changed? && paid? }

  # custom validation to check if the total amount of the payment request is less than or equal to the total amount of the scope of work
  validate :check_campaign_selected_media_plan
  validate :check_total_amount, on: :create
  validate :beneficiary_is_on_scope_of_works
  validate :social_media_account_is_not_assigned_to_management

  after_initialize :set_default_status, if: :new_record?

  # callbacks
  before_save :calculate_total_ppn, :calculate_total_pph, :calculate_total_payment

  # Beneficiaries are either SocialMediaAccount or Management
  # Used for form select input
  BENEFICIARY_TYPES = %w[SocialMediaAccount Management].freeze

  delegate :name, to: :beneficiary, prefix: true
  delegate :name, to: :requestor, prefix: true

  def self.ransackable_attributes(auth_object = nil)
    ["amount", "beneficiary_id", "beneficiary_type", "campaign_id", "created_at", "due_date", "id", "id_value", "notes", "paid_at", "payer_id", "pph_option", "ppn", "requestor_id", "status", "tax_invoice_number", "total_payment", "total_pph", "total_ppn", "updated_at"]
  end

  def beneficiary_sgid=(value)
    self.beneficiary = GlobalID::Locator.locate_signed(value, for: :polymorphic_select)
  end

  def rejected_or_paid?
    rejected? || paid?
  end

  def beneficiary_sgid
  end

  def paid!
    update(status: :paid, paid_at: Time.zone.now)
  end

  def calculate_total_ppn
    self.total_ppn = ppn? ? amount * 0.11 : 0
  end

  def calculate_total_pph
    self.total_pph = gross_up? ? 0 : total_pph
  end

  def calculate_total_payment
    self.total_payment = amount + total_ppn - total_pph
  end

  def total_payment_that_needs_to_be_paid
    if beneficiary.is_a?(SocialMediaAccount)
      scope_of_works.where(social_media_account: beneficiary).sum(:total)
    elsif beneficiary.is_a?(Management)
      scope_of_works.where(management: beneficiary).sum(:total)
    end
  end

  def remaining_amount_that_needs_to_be_paid
    total_payment_that_needs_to_be_paid - total_payment_that_has_been_paid_or_requested
  end

  def total_payment_that_has_been_paid_or_requested
    PaymentRequest.where(beneficiary: beneficiary, campaign: campaign, status: %i[pending paid processed]).sum(:amount)
  end

  private
    def check_campaign_selected_media_plan
      errors.add(:campaign, 'should have selected media plan') if campaign && campaign.selected_media_plan.nil?
    end

    def check_total_amount
      return if scope_of_works.blank?
      return if amount.blank?

      sow_total = total_payment_that_needs_to_be_paid
      payment_request_total = total_payment_that_has_been_paid_or_requested

      if sow_total.nil? || sow_total == 0
        errors.add(:amount, 'beneficiary scope of work total is 0')
        return
      end

      if amount > (sow_total - payment_request_total)
        errors.add(:amount, 'should not exceed the total amount of the scope of work')
      end
    end

    def beneficiary_is_on_scope_of_works
      if beneficiary.is_a?(SocialMediaAccount)
        errors.add(:beneficiary, 'is not on scope of works') if scope_of_works && scope_of_works.where(social_media_account: beneficiary).blank?
      elsif beneficiary.is_a?(Management)
        errors.add(:beneficiary, 'is not on scope of works') if scope_of_works && scope_of_works.where(management: beneficiary).blank?
      end
    end

    def social_media_account_is_not_assigned_to_management
      if beneficiary.is_a?(SocialMediaAccount)
        # errors.add(:beneficiary, 'is assigned to the management') if scope_of_works && scope_of_works.where("social_media_account_id = ? and management_id is not null", beneficiary.id).exists?
        errors.add(:beneficiary, 'is assigned to the management') if scope_of_works && scope_of_works.where(social_media_account_id: beneficiary).where.not(management: nil).exists?
      end
    end

    def scope_of_works
      return if campaign.blank?
      return if campaign && campaign.selected_media_plan.nil?

      campaign.selected_media_plan.scope_of_works
    end

    def set_default_status
      self.status ||= :pending
    end
end
