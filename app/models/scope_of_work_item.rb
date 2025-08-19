# frozen_string_literal: true

class ScopeOfWorkItem < ApplicationRecord
  PRICES = [ 'story', 'story_session', 'feed_photo',
             'feed_video', 'reel', 'live', 'owning_asset',
             'tap_link', 'link_in_bio', 'live_attendance', 'host',
             'comment', 'photoshoot', 'other' ]


  belongs_to :scope_of_work
  has_one :social_media_account, through: :scope_of_work
  has_one :social_media_publication, dependent: :destroy
  delegate :media_plan, to: :scope_of_work
  delegate :campaign, to: :scope_of_work

  ##
  # This is due to policy which says that
  # 1 sow can have many items with the same type
  before_save :make_quantity_as_one

  ##
  # Callbacks related to price / total
  before_save :calculate_subtotal
  after_save :calculate_scope_of_work_total, :recalculate_metrics
  after_destroy :calculate_scope_of_work_total, :recalculate_metrics

  ##
  # if sow item's posted_at is set
  # then the budget is spent
  # therefore sow's budget_spent is updated
  after_save :update_budget_spent

  # validates :name, presence: true
  # validates :quantity, presence: true
  # validates :price, presence: true
  # validates :name, inclusion: { in: PRICES }

  # scopes
  scope :posted, -> { where.not(posted_at: nil) }
  scope :posted_between, -> (start_date, end_date) { where(posted_at: start_date..end_date) }
  scope :not_posted, -> { left_outer_joins(:social_media_publication).where(social_media_publications: { id: nil }) }

  scope :scheduled, -> { where.not(scheduled_at: nil) }
  scope :scheduled_between, -> (start_date, end_date) { where(scheduled_at: start_date..end_date) }
  scope :scheduled_month, -> (month) { where(scheduled_at: month.beginning_of_month..month.end_of_month) }

  # group by social media account's size
  def self.group_by_social_media_account_size
    self.joins(:social_media_account).group('social_media_accounts.size')
  end

  def can_be_track_automatically?
    return true if self.campaign.platform == 'tiktok'
    return true if name.in?(%w[story feed_photo feed_video reel])
    false
  end

  private
    def make_quantity_as_one
      self.quantity = 1
    end

    def calculate_subtotal
      self.subtotal = self.price.to_i * (self.quantity || 0)
      self.subtotal_sell_price = self.sell_price.to_i * (self.quantity || 0)
    end

    def calculate_scope_of_work_total
      self.scope_of_work.update(total: self.scope_of_work.scope_of_work_items.sum(:subtotal))
      self.scope_of_work.update(total_sell_price: self.scope_of_work.scope_of_work_items.sum(:subtotal_sell_price))
    end

    def recalculate_metrics(*args)
      media_plan.recalculate_metrics
    end

    def update_budget_spent
      if self.posted_at.present?
        self.scope_of_work.calculate_budget_spent
      end
    end
end
