# frozen_string_literal: true

class Organization < ApplicationRecord
  # validations
  validates :name, presence: true

  # relationships
  has_many :users
  has_one_attached :logo, dependent: :destroy do |attachable|
    attachable.variant :default, resize_to_limit: [349, 42]
  end
  has_many :competitor_reviews, dependent: :destroy
end
