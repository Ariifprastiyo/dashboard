# frozen_string_literal: true

class Influencer < ApplicationRecord
  include Discard::Model

  enum :gender, male: 0, female: 1

  has_many :social_media_accounts

  validates :name, presence: true
  validates :no_npwp, presence: true, if: :have_npwp?
  # validates :pic_phone_number, presence: true
  # validates :pic, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["account_number", "address", "bank_code", "created_at", "discarded_at", "email", "gender", "have_npwp", "id", "id_value", "name", "no_ktp", "no_npwp", "phone_number", "pic", "pic_phone_number", "updated_at"]
  end

  def discard_with_dependencies
    ActiveRecord::Base.transaction do
      self.social_media_accounts.discard_all
      self.discard
    end
  end

  def valid_npwp?
    return true unless have_npwp?

    no_npwp.present?
  end

  def personal_data_completed?
    no_ktp.present? && valid_npwp? && bank_code.present? && account_number.present? && address.present?
  end

  def self.find_or_create_by_username(username, platform)
    influencer = Influencer.find_by(name: username)
    if influencer.blank?
      influencer = Influencer.create(name: username, have_npwp: false)
    end

    # create social_media_account too
    social_media_account = SocialMediaAccount.create(influencer_id: influencer.id, username: username, platform: platform)

    [influencer, social_media_account]
  end
end
