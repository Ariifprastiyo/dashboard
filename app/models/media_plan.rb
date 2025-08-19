# frozen_string_literal: true

class MediaPlan < ApplicationRecord
  class MediaPlanError < StandardError; end

  # validations
  validates :name, presence: true

  # relationships
  belongs_to :campaign
  has_many :scope_of_works, dependent: :destroy
  has_many :scope_of_work_items, through: :scope_of_works
  has_many :social_media_accounts,
            through: :scope_of_works,
            before_add: :check_social_media_account

  # custom validation
  validates :scope_of_work_template, presence: true
  validate :validate_scope_of_work_template

  before_destroy :check_if_main_media_plan

  def self.ransackable_attributes(auth_object = nil)
    ["campaign_id", "created_at", "estimated_budget", "estimated_engagement_rate",
      "estimated_engagement_rate_branding_post", "estimated_impression",
      "estimated_reach", "id", "id_value", "name", "scope_of_work_template",
      "updated_at", "cancelled_at", "current_row", "error_messages",
      "job_id", "total_error", "total_row"]
  end

  def recalculate_metrics(*args)
    reload
    calculate_estimated_engagement_rate
    calculate_estimated_impression
    calculate_estimated_reach
  end

  def calculate_estimated_engagement_rate
    if scope_of_work_items.sum(:quantity) == 0
      total = 0
    else
      er = scope_of_works.with_quantity.map { |sow| sow.social_media_account.estimated_engagement_rate_average }
      total = er.sum(0.0) / er.size
    end

    update(estimated_engagement_rate: total || 0.0)
  end

  def calculate_estimated_impression
    total = 0
    scope_of_works.each do |sow|
      total += sow.scope_of_work_items.sum(:quantity) * sow.social_media_account.estimated_impression
    end
    self.update(estimated_impression: total)
  end

  def calculate_estimated_reach
    total = 0
    scope_of_works.each do |sow|
      total += sow.scope_of_work_items.sum(:quantity) * sow.social_media_account.estimated_reach
    end

    self.update(estimated_reach: total)
  end

  def is_main_media_plan?
    campaign.selected_media_plan == self
  end

  def bulk_markup_sell_price(social_media_account_sizes, sell_price_percentages)
    social_media_account_sizes.each do |social_media_account_size|
      size = social_media_account_size[0]
      value = social_media_account_size[1]
      next if value.to_i.zero?

      scope_of_works = self.scope_of_works.includes(:social_media_account).where(social_media_account: { size: size })
      next if scope_of_works.empty?

      scope_of_works.each do |scope_of_work|
        BulkMarkupSellPriceJob.perform_later(scope_of_work_id: scope_of_work.id, sell_price_percentages: sell_price_percentages)
      end
    end
  end

  def total_sell_price
    scope_of_works.sum(:total_sell_price)
  end

  def cpv
    return 0 if estimated_impression.zero? || total_sell_price.zero?
    total_sell_price / estimated_impression
  end

  def cpr
    return 0 if estimated_reach.zero? || total_sell_price.zero?
    total_sell_price / estimated_reach
  end

  # calculated based on the sum of estimated_total_engagement of all social media accounts
  def cpe
    total_social_media_accounts_engagement = social_media_accounts.collect { |sma| sma.estimated_total_engagement }.sum

    return 0 if total_social_media_accounts_engagement.zero? || total_sell_price.zero?

    total_sell_price / total_social_media_accounts_engagement
  end

  private
    # validate scope of work template, must be a hash with ScopeOfWorkItem::PRICES as keys
    def validate_scope_of_work_template
      return if scope_of_work_template.nil?
      errors.add(:scope_of_work_template, 'must be a hash') unless scope_of_work_template.is_a?(Hash)
      scope_of_work_template.keys.each do |key|
        errors.add(:scope_of_work_template, "invalid key #{key}") unless ScopeOfWorkItem::PRICES.include?(key.to_s)
      end
    end

    def check_social_media_account(social_media_account)
      raise MediaPlan::MediaPlanError.new 'social_media_account_id has already been added' if self.social_media_accounts.include?(social_media_account)
    end

    def check_if_main_media_plan
      raise ActiveRecord::DeleteRestrictionError.new 'Media Plan is the main media plan for the campaign' if is_main_media_plan?
    end
end
