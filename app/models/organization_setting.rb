# frozen_string_literal: true

class OrganizationSetting < ApplicationRecord
  has_one_attached :logo do |attachable|
    attachable.variant :default, resize_to_limit: [1013, 122]
  end

  has_one_attached :logo_login

  after_commit :purge_unattached_files

private
  def purge_unattached_files
    # ActiveStorage::Blob.unattached.each(&:purge_later)
  end
end
