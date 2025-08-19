# frozen_string_literal: true

class CompetitorReview < ApplicationRecord
  belongs_to :organization, optional: true
  has_and_belongs_to_many :campaigns, optional: true

  validates :title, presence: true
  validates :organization_id, presence: true
end
