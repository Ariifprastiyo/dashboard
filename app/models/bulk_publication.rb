# frozen_string_literal: true

class BulkPublication < ApplicationRecord
  belongs_to :campaign
  has_one_attached :bulk_publication_file, dependent: :destroy

  # validations
  validates :total_row, numericality: { greater_than: 0 }
  validates :bulk_publication_file, attached: true
  validate :validate_bulk_publication_file_type

  def self.ransackable_attributes(auth_object = nil)
    ["campaign_id", "cancelled_at", "created_at", "current_row", "error_messages", "id", "id_value", "job_id", "total_error", "total_row", "updated_at"]
  end

  private
    def validate_bulk_publication_file_type
      return unless bulk_publication_file.attached?

      unless bulk_publication_file.content_type.in?(%w[application/vnd.openxmlformats-officedocument.spreadsheetml.sheet application/vnd.ms-excel])
        errors.add(:bulk_publication_file, 'must be an Excel file (XLS or XLSX)')
      end
    end
end
