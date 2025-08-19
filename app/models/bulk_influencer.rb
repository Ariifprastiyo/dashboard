# frozen_string_literal: true

class BulkInfluencer < ApplicationRecord
  has_one_attached :bulk_influencer_file, dependent: :destroy

  validates :bulk_influencer_file, attached: true
  validate :acceptable_file_type

  scope :recent_records, -> { where('created_at > ?', 1.month.ago) }
  scope :old_records, -> { where('created_at < ?', 1.month.ago) }

  private
    def acceptable_file_type
      return unless bulk_influencer_file.attached?

      unless bulk_influencer_file.content_type.in?(['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'])
        errors.add(:bulk_influencer_file, 'must be an XLSX file')
      end
    end
end
