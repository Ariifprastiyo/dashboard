# frozen_string_literal: true

class Management < ApplicationRecord
  include Discard::Model

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_and_belongs_to_many :social_media_accounts, -> { includes({ profile_picture_attachment: :blob }, :categories) }, join_table: "managements_accounts"
  has_many :payment_requests, as: :beneficiary

  def self.ransackable_attributes(auth_object = nil)
    ["account_number", "address", "bank_code", "created_at", "discarded_at", "id", "id_value", "name", "no_ktp", "no_npwp", "phone", "pic_email", "pic_name", "updated_at"]
  end
end
