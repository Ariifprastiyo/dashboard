# frozen_string_literal: true

class ScopeOfWork < ApplicationRecord
  belongs_to :media_plan
  belongs_to :social_media_account
  belongs_to :management, optional: true

  has_many :scope_of_work_items, dependent: :destroy
  accepts_nested_attributes_for :scope_of_work_items, allow_destroy: true
  has_many :social_media_publications, dependent: :destroy
  has_one_attached :agreement_letter, dependent: :destroy
  has_many :payment_requests
  belongs_to :management, optional: true


  delegate :campaign, to: :media_plan

  before_create :set_uuid
  before_save :calculate_total
  after_create :create_scope_of_work_items
  after_create :update_social_media_account_stats

  enum :status, { pending: 0, accepted: 1, rejected: 2 }, default: :pending

  # make sure only 1 sow per account per media plan
  validates :social_media_account_id, uniqueness: { scope: :media_plan_id, message: 'has already been added' }

  # scope to get all scope of work by size of the social media account
  scope :by_social_media_account_size, -> (size) {
    joins(:social_media_account).where(social_media_accounts: { size: size })
  }

  # scope which returns all scope of work item that has quantity > 0
  scope :with_quantity, -> { joins(:scope_of_work_items).where('scope_of_work_items.quantity > 0') }

  scope :with_aggrement_letter, -> (attachment_status) {
    status = attachment_status.parameterize.underscore.to_sym
    case status
    when :upload
      joins(:agreement_letter_attachment).where.not(agreement_letter_attachment: { blob_id: nil }).distinct
    when :not_uploaded
      includes(:agreement_letter_attachment).where(agreement_letter_attachment: { blob_id: nil }).distinct
    end
  }

  def self.ransackable_attributes(auth_object = nil)
    ["agreement_absent_day", "agreement_end_date", "agreement_maximum_payment_day", "agreement_payment_terms_note", "budget_spent", "budget_spent_sell_price", "comments_count", "created_at", "engagement_rate", "id", "id_value", "impressions", "last_submitted_at", "likes_count", "management_id", "media_plan_id", "notes", "reach", "share_count", "social_media_account_id", "status", "total", "total_sell_price", "updated_at", "uuid"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["agreement_letter_attachment", "agreement_letter_blob", "management", "media_plan", "payment_requests", "scope_of_work_items", "social_media_account", "social_media_publications"]
  end

  def self.ransackable_scopes(auth_object = nil)
    [:with_aggrement_letter]
  end

  def self.status_options
    ScopeOfWork.statuses.map { |k, v| [k.humanize, v] }
  end

  def discard_with_dependencies
    ActiveRecord::Base.transaction do
      self.scope_of_work_items.destroy_all
      self.destroy
    end
  end

  def recalculate_metrics
    reload
    calculate_comments_count
    calculate_likes_count
    calculate_share_count
    calculate_impressions
    calculate_reach
    calculate_engagement_rate
    save
  end

  def calculate_comments_count
    self.comments_count = self.social_media_publications.sum(:comments_count) || 0
  end

  def calculate_likes_count
    self.likes_count = self.social_media_publications.sum(:likes_count) || 0
  end

  def calculate_share_count
    self.share_count = self.social_media_publications.sum(:share_count) || 0
  end

  def calculate_impressions
    self.impressions = self.social_media_publications.sum(:impressions) || 0
  end

  def calculate_reach
    self.reach = self.social_media_publications.sum(:reach) || 0
  end

  def calculate_engagement_rate
    self.engagement_rate = self.social_media_publications.average(:engagement_rate).to_f || 0
  end

  def calculate_budget_spent
    budget_spent = self.scope_of_work_items.posted.sum(:subtotal)
    budget_spent_sell_price = self.scope_of_work_items.posted.sum(:subtotal_sell_price)
    update(budget_spent: budget_spent, budget_spent_sell_price: budget_spent_sell_price)
  end

  # Cost per view is calculated by dividing the total_sell_price cost by the total views
  # Only for TikTok
  def cpv
    return 0 if self.impressions == 0

    self.total_sell_price / self.impressions
  end

  # Cost per reach is calculated by dividing the total_sell_price cost by the total reach
  # Only for Instagram
  def cpr
    return 0 if self.reach == 0

    self.total_sell_price / self.reach
  end

  # Cost per engagement is calculated by dividing the total_sell_price cost by the total engagement
  # For all platforms
  def cpe
    return 0 unless self.engagement_rate.present? && self.engagement_rate.finite?
    return 0 if self.engagement_rate == 0 || self.engagement_rate.nil?

    self.total_sell_price / self.engagement_rate
  end

  def sow_item_summary
    item_summary = self.scope_of_work_items.group(:name).sum(:quantity)

    # transform into string like this "1x Post, 2x Story"
    item_summary.map { |k, v| "#{v}x #{k}" }.join(', ')
  end

  def total_engagement
    self.comments_count + self.likes_count + self.share_count
  end

  # impressions to followers ratio
  def view_rate
    return 0 if self.reach == 0 || self.social_media_account.followers == 0

    self.reach / self.social_media_account.followers.to_f * 100
  end

  private
    def set_uuid
      self.uuid = SecureRandom.uuid
    end

    def calculate_total
      self.total = self.scope_of_work_items.sum(:subtotal)
    end

    def create_scope_of_work_items
      media_plan.scope_of_work_template.each do |sow|
        name = sow[0]
        quantity = sow[1]
        price = self.social_media_account[:"#{name}_price"]
        sell_price = self.social_media_account[:"#{name}_sell_price"]

        if quantity.present?
          quantity = quantity.to_i
        else
          next
        end

        quantity.times do
          self.scope_of_work_items.create(
            name: name,
            price: price,
            sell_price: sell_price,
            quantity: 1)
        end
      end
    end

    def update_social_media_account_stats
      SingleSocialMediaAccountUpdaterJob.perform_later(
        self.social_media_account.id, self.media_plan.id
      )
    end
end
